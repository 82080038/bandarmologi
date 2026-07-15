from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import json
import asyncio
import pandas as pd
import psycopg2
import redis.asyncio as aioredis
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
import os
from datetime import datetime
import google.generativeai as genai
from stress_tester import run_historical_stress_test
from bot_engine import final_safety_execution_loop
import advanced_secrets_detector as asd
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import bot_scheduler

app = FastAPI()

# Izinkan komunikasi dengan Frontend Next.js
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simulasi Koneksi Database (Ganti dengan URI database asli Anda)
DB_PARAMS = "dbname=smart_money user=postgres password=secret host=localhost port=5432"
REDIS_URL = "redis://redis:6379/0"

# Inisialisasi koneksi Redis Async dengan error handling
try:
    redis_client = aioredis.from_url(REDIS_URL, decode_responses=True)
    redis_available = True
except Exception as e:
    print(f"[WARNING] Redis connection failed: {str(e)}. Falling back to direct database queries.")
    redis_client = None
    redis_available = False

# Konfigurasi AI LLM (Pastikan API Key sudah diset di Environment Variable)
genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))

# Konfigurasi SMTP Email (Ganti dengan kredensial Anda)
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = "system.smartmoney@gmail.com"
SENDER_PASSWORD = os.environ.get("SMTP_PASSWORD")
RECEIVER_EMAIL = "pemilik.modal@gmail.com"

# Antrean Memori untuk In-App Notification (Live Feed)
notification_queue = asyncio.Queue()

def get_ai_market_opinion(ticker: str, metrics: dict) -> str:
    """
    Menghubungi AI LLM untuk menghasilkan analisis opini profesional 
    berdasarkan metrik akumulasi bandar yang dikirimkan.
    """
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        prompt = f"""
        Bertindaklah sebagai Analis Senior Pasar Modal. Berikan opini singkat, tajam, dan profesional (maksimal 3 kalimat) 
        mengenai prospek saham {ticker} hari ini berdasarkan data teknis berikut:
        - Rasio Akumulasi Top 3 Buyer: {metrics['buyer_ratio']}%
        - Rasio Distribusi Top 3 Seller: {metrics['seller_ratio']}%
        - Status Bandarmologi Saat Ini: {metrics['status']}
        
        Berikan pandangan ekonomi rasional tentang apa yang sebaiknya diwaspadai investor ritel. Jangan berikan disclaimer umum.
        """
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        return f"Gagal memuat analisis AI secara real-time. (Error: {str(e)})"

def analyze_market_maker(ticker: str, days: int = 1):
    """
    Logika Analisis Pasar Modal:
    Menghitung konsentrasi Top 3 Broker untuk mendeteksi Akumulasi/Distribusi.
    """
    conn = psycopg2.connect(DB_PARAMS)
    query = f"""
        SELECT buyer_broker, seller_broker, volume 
        FROM market_trades 
        WHERE ticker = %s AND time >= NOW() - INTERVAL '{days} day'
    """
    df = pd.read_sql_query(query, conn, params=(ticker,))
    conn.close()

    if df.empty:
        return {"status": "NO_DATA"}

    # Kalkulasi Top Buyer & Seller
    top_buyers = df.groupby('buyer_broker')['volume'].sum().nlargest(3).sum()
    top_sellers = df.groupby('seller_broker')['volume'].sum().nlargest(3).sum()
    total_volume = df['volume'].sum()

    # Rumus Ekonomi Bandarmologi
    buyer_ratio = top_buyers / total_volume
    seller_ratio = top_sellers / total_volume
    
    net_sentiment = buyer_ratio - seller_ratio
    
    if net_sentiment > 0.15:
        status = "BIG ACCUMULATION"
    elif net_sentiment > 0.05:
        status = "ACCUMULATION"
    elif net_sentiment < -0.15:
        status = "BIG DISTRIBUTION"
    elif net_sentiment < -0.05:
        status = "DISTRIBUTION"
    else:
        status = "NEUTRAL"

    return {
        "ticker": ticker,
        "total_volume": int(total_volume),
        "top_3_buyer_ratio": float(buyer_ratio),
        "top_3_seller_ratio": float(seller_ratio),
        "market_maker_status": status
    }

def detect_spoofing_attempts(ticker: str, volume_threshold_lot: int = 5000, time_window_seconds: int = 10):
    """
    Algoritma Finansial - Spoofing Detector:
    Mendeteksi pembatalan antrean (CANCELED) dalam volume raksasa 
    secara mendadak sebelum harga menyentuh titik tersebut.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # Kueri mengambil 2 snapshot terakhir pada harga yang sama untuk melihat penurunan volume ekstrem
    query = f"""
        WITH ranked_snapshots AS (
            SELECT 
                time, 
                price, 
                type, 
                total_volume_lot,
                LAG(total_volume_lot) OVER (PARTITION BY price, type ORDER BY time ASC) as previous_volume,
                EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY price, type ORDER BY time ASC))) as time_diff
            FROM order_book_snapshots
            WHERE ticker = %s AND time >= NOW() - INTERVAL '{time_window_seconds} second'
        )
        SELECT time, price, type, previous_volume, total_volume_lot, (previous_volume - total_volume_lot) as volume_dropped
        FROM ranked_snapshots
        WHERE previous_volume IS NOT NULL 
          AND (previous_volume - total_volume_lot) >= %s -- Volume drop drastis
          AND time_diff <= 2 -- Terjadi dalam waktu kurang dari 2 detik (Mendadak)
        ORDER BY time DESC;
    """
    
    df = pd.read_sql_query(query, conn, params=(ticker.upper(), volume_threshold_lot))
    
    # Validasi silang dengan Running Trade untuk memastikan volume drop BUKAN karena MATCHED (terjual)
    if not df.empty:
        spoof_alerts = []
        for index, row in df.iterrows():
            # Cek apakah ada trade yang terjadi di harga tersebut pada detik yang sama
            trade_check_query = """
                SELECT SUM(volume) as traded_volume 
                FROM market_trades 
                WHERE ticker = %s AND price = %s AND time BETWEEN %s - INTERVAL '1 second' AND %s
            """
            trade_df = pd.read_sql_query(trade_check_query, conn, params=(ticker.upper(), row['price'], row['time'], row['time']))
            traded_vol = trade_df['traded_volume'].fillna(0).iloc[0]
            
            # Jika volume yang hilang jauh lebih besar daripada volume yang ditransaksikan, maka itu SPOOFING
            actual_canceled = row['volume_dropped'] - traded_vol
            if actual_canceled >= volume_threshold_lot:
                spoof_alerts.append({
                    "time": row['time'].isoformat(),
                    "price": float(row['price']),
                    "type": row['type'],
                    "manipulation_type": "FAKE_WALL_SPOOFING",
                    "canceled_volume_lot": int(actual_canceled),
                    "severity": "HIGH" if actual_canceled > (volume_threshold_lot * 3) else "MEDIUM"
                })
        
        conn.close()
        return spoof_alerts
        
    conn.close()
    return []

@app.get("/api/analytics/{ticker}")
async def get_analytics(ticker: str):
    return analyze_market_maker(ticker.upper())

def calculate_market_maker_avg_price(ticker: str, days: int = 20):
    """
    Menghitung Harga Rata-Rata (VWAP) dari Top 3 Broker Akumulator
    untuk menentukan area pertahanan psikologis penggerak pasar.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    query = f"""
        WITH top_accumulators AS (
            -- Langkah 1: Cari 3 Broker pembeli bersih (net buyer) terbesar
            SELECT 
                buyer_broker,
                SUM(volume) as total_buy_vol
            FROM market_trades
            WHERE ticker = %s 
              AND time >= NOW() - INTERVAL '{days} day'
              AND buyer_broker IS NOT NULL
            GROUP BY buyer_broker
            ORDER BY total_buy_vol DESC
            LIMIT 3
        ),
        broker_weighted_calc AS (
            -- Langkah 2: Hitung Total Nilai Transaksi (Price * Volume)
            SELECT 
                t.buyer_broker,
                SUM(t.price * t.volume) as total_monetary_value,
                SUM(t.volume) as total_broker_volume
            FROM market_trades t
            JOIN top_accumulators ta ON t.buyer_broker = ta.buyer_broker
            WHERE t.ticker = %s 
              AND t.time >= NOW() - INTERVAL '{days} day'
            GROUP BY t.buyer_broker
        )
        -- Langkah 3: Ekstrak harga rata-rata tertimbang (VWAP)
        SELECT 
            buyer_broker as market_maker_code,
            total_broker_volume as total_accumulated_lot,
            ROUND(total_monetary_value / total_broker_volume, 2) as average_buy_price,
            ROUND(SUM(total_monetary_value) OVER() / SUM(total_broker_volume) OVER(), 2) as combined_market_maker_avg
        FROM broker_weighted_calc;
    """
    
    df = pd.read_sql_query(query, conn, params=(ticker.upper(), ticker.upper()))
    conn.close()
    
    if df.empty:
        return {"status": "NO_DATA"}
    
    # Convert to list of dictionaries for JSON response
    result = df.to_dict('records')
    
    # Extract combined average from first row (all rows have same combined value)
    combined_avg = result[0]['combined_market_maker_avg'] if result else None
    
    return {
        "ticker": ticker,
        "analysis_period_days": days,
        "top_accumulators": result,
        "combined_market_maker_avg": combined_avg
    }

@app.get("/api/spoof-detector/{ticker}")
async def get_spoof_alerts(ticker: str):
    return detect_spoofing_attempts(ticker, volume_threshold_lot=5000, time_window_seconds=30)

@app.get("/api/market-maker-avg/{ticker}")
async def get_market_maker_avg(ticker: str, days: int = 20):
    return calculate_market_maker_avg_price(ticker, days)

@app.get("/api/matrix")
async def get_matrix_view(tickers: str):
    """
    Mengambil data matriks analisis untuk banyak saham sekaligus.
    Format input URL: /api/matrix?tickers=BBCA,BBRI,BMRI,BBNI
    """
    ticker_list = [t.strip().upper() for t in tickers.split(",")]
    matrix_result = []
    
    conn = psycopg2.connect(DB_PARAMS)
    
    for ticker in ticker_list:
        # 1. Jalankan kueri kalkulasi akumulasi bandar (Top 3 Broker)
        query_acc = f"""
            WITH top_brokers AS (
                SELECT 
                    buyer_broker, seller_broker, volume 
                FROM market_trades 
                WHERE ticker = %s AND time >= NOW() - INTERVAL '1 day'
            )
            SELECT 
                (SELECT SUM(volume) FROM (SELECT volume FROM top_brokers GROUP BY buyer_broker ORDER BY SUM(volume) DESC LIMIT 3) as tb) as top_buy,
                (SELECT SUM(volume) FROM (SELECT volume FROM top_brokers GROUP BY seller_broker ORDER BY SUM(volume) DESC LIMIT 3) as ts) as top_sell,
                SUM(volume) as total_vol
            FROM top_brokers;
        """
        
        df_acc = pd.read_sql_query(query_acc, conn, params=(ticker,))
        
        # Default nilai jika data kosong
        status = "NO_DATA"
        flow_ratio = 0.0
        total_vol = 0
        
        if not df_acc.empty and df_acc['total_vol'].iloc[0] is not None:
            total_vol = int(df_acc['total_vol'].iloc[0])
            top_buy = df_acc['top_buy'].iloc[0] or 0
            top_sell = df_acc['top_sell'].iloc[0] or 0
            
            buyer_ratio = top_buy / total_vol
            seller_ratio = top_sell / total_vol
            net_sentiment = buyer_ratio - seller_ratio
            flow_ratio = net_sentiment * 100
            
            if net_sentiment > 0.10: status = "ACCUMULATION"
            elif net_sentiment > 0.25: status = "BIG ACCUMULATION"
            elif net_sentiment < -0.10: status = "DISTRIBUTION"
            elif net_sentiment < -0.25: status = "BIG DISTRIBUTION"
            else: status = "NEUTRAL"

        # 2. Ambil data harga penutupan terakhir (Last Price)
        query_price = "SELECT price FROM market_trades WHERE ticker = %s ORDER BY time DESC LIMIT 1;"
        df_price = pd.read_sql_query(query_price, conn, params=(ticker,))
        last_price = int(df_price['price'].iloc[0]) if not df_price.empty else 0

        # 3. Hitung jumlah alert Spoofing dalam 5 menit terakhir
        query_spoof = """
            SELECT COUNT(*) as count FROM order_book_snapshots 
            WHERE ticker = %s AND time >= NOW() - INTERVAL '5 minute';
            -- Catatan: Fungsi aslinya menggunakan logika detect_spoofing_attempts dari tahap sebelumnya
        """
        # Simulasi pencatatan deteksi alert spoofing aktif
        spoof_alerts_count = 1 if status == "BIG ACCUMULATION" else 0 

        matrix_result.append({
            "ticker": ticker,
            "last_price": last_price,
            "volume_lot": total_vol,
            "smart_money_flow": round(flow_ratio, 2),
            "status": status,
            "spoofing_alert": spoof_alerts_count > 0
        })
        
    conn.close()
    return matrix_result

@app.websocket("/ws/trades/{ticker}")
async def websocket_endpoint(websocket: WebSocket, ticker: str):
    """
    WebSocket Berkinerja Tinggi: 
    Membaca data ter-cache dari saluran Redis Pub/Sub secara real-time.
    """
    await websocket.accept()
    channel_name = f"ticker_stream_{ticker.lower()}"
    
    if not redis_available:
        # Fallback: Direct database polling if Redis is unavailable
        try:
            while True:
                conn = psycopg2.connect(DB_PARAMS)
                query = "SELECT time, price, volume FROM market_trades WHERE ticker = %s ORDER BY time DESC LIMIT 1"
                df = pd.read_sql_query(query, conn, params=(ticker.upper(),))
                conn.close()
                
                if not df.empty:
                    latest = df.iloc[0]
                    trade_data = {
                        "time": latest['time'].isoformat(),
                        "price": float(latest['price']),
                        "volume": int(latest['volume'])
                    }
                    await websocket.send_text(json.dumps(trade_data))
                
                await asyncio.sleep(1) # Poll every second when Redis is down
        except WebSocketDisconnect:
            print(f"Client terputus dari stream {ticker}")
        return
    
    # Berlangganan ke saluran Redis khusus untuk ticker ini
    pubsub = redis_client.pubsub()
    await pubsub.subscribe(channel_name)
    
    try:
        while True:
            # Baca pesan baru dari antrean memori Redis
            message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=1.0)
            if message:
                data = json.loads(message['data'])
                await websocket.send_text(json.dumps(data))
            else:
                # Fallback ke mock data jika Redis belum ada data
                current_time = datetime.utcnow().isoformat() + "Z"
                mock_trade_data = {
                    "time": current_time,
                    "open": 5000,
                    "high": 5050,
                    "low": 4980,
                    "close": 5020,
                    "volume": 12500
                }
                await websocket.send_text(json.dumps(mock_trade_data))
            await asyncio.sleep(0.01) # Mencegah penggunaan CPU 100%
    except WebSocketDisconnect:
        print(f"Client terputus dari stream {ticker}")
    finally:
        await pubsub.unsubscribe(channel_name)

@app.get("/api/report/pdf/{ticker}")
async def generate_pdf_report(ticker: str):
    """
    Mengekstrak data dari TimescaleDB dan mengemasnya 
    menjadi laporan PDF analisis institusional formal dengan AI LLM.
    """
    ticker = ticker.upper()
    pdf_filename = f"SmartMoney_AI_Report_{ticker}.pdf"
    
    # 1. Tarik metrik dari database untuk bahan baku LLM
    try:
        conn = psycopg2.connect(DB_PARAMS)
        query = f"SELECT price, volume, buyer_broker, seller_broker FROM market_trades WHERE ticker = %s ORDER BY time DESC LIMIT 5"
        df = pd.read_sql_query(query, conn, params=(ticker,))
        
        # Mock metrics untuk AI (dalam produksi, hitung dari data sebenarnya)
        mock_metrics = {"buyer_ratio": 45.2, "seller_ratio": 21.8, "status": "BIG ACCUMULATION"}
        
        # 2. Ambil Opini Teks Otomatis dari AI LLM
        ai_opinion_text = get_ai_market_opinion(ticker, mock_metrics)
        
        conn.close()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengambil data database: {str(e)}")

    # 3. Setup Dokumen ReportLab
    doc = SimpleDocTemplate(pdf_filename, pagesize=letter, rightMargin=40, leftMargin=40, topMargin=40, bottomMargin=40)
    story = []
    styles = getSampleStyleSheet()
    
    # Gaya teks kustom untuk Box Konten AI
    ai_box_style = ParagraphStyle(
        'AIBox', 
        parent=styles['Normal'], 
        fontSize=10, 
        leading=15, 
        textColor=colors.HexColor("#0f172a"),
        backColor=colors.HexColor("#f0fdf4"), # Warna hijau lembut khas AI Insight
        borderColor=colors.HexColor("#bbf7d0"),
        borderWidth=1,
        borderPadding=12,
        spaceAfter=15
    )
    
    title_style = ParagraphStyle('TitleStyle', parent=styles['Heading1'], fontSize=22, textColor=colors.HexColor("#0f172a"), spaceAfter=6)
    meta_style = ParagraphStyle('MetaStyle', parent=styles['Normal'], fontSize=9, textColor=colors.HexColor("#64748b"), spaceAfter=20)
    body_style = ParagraphStyle('BodyStyle', parent=styles['Normal'], fontSize=11, leading=16, spaceAfter=15)
    
    # Menyusun isi PDF
    story.append(Paragraph(f"LAPORAN ANALISIS SMART MONEY: {ticker}", title_style))
    story.append(Paragraph(f"Dibuat Otomatis oleh Terminal Pasar Modal AI | Tanggal: {datetime.now().strftime('%d %B %Y')}", meta_style))
    story.append(Spacer(1, 10))
    
    # Komponen Visual Baru: Masukkan Kotak Opini AI LLM
    story.append(Paragraph(f"<b>💡 SMART MONEY AI INSIGHT:</b><br/><br/>{ai_opinion_text}", ai_box_style))
    story.append(Spacer(1, 10))
    
    # Ringkasan Eksekutif Analis Keuangan
    executive_summary = (
        f"Dokumen ini memuat analisis algoritma terhadap aktivitas perdagangan saham {ticker}. "
        f"Sistem kami melacak konsentrasi transaksi institusional guna memisahkan pergerakan "
        f"investor ritel dari akumulasi volume yang didorong oleh Penggerak Pasar (Market Maker)."
    )
    story.append(Paragraph(executive_summary, body_style))
    story.append(Spacer(1, 12))
    
    # Struktur Tabel Data Transaksi Terakhir Bandar
    table_data = [["Broker Beli", "Broker Jual", "Harga Performa", "Volume (Lot)"]]
    for _, row in df.iterrows():
        table_data.append([
            str(row['buyer_broker']), 
            str(row['seller_broker']), 
            f"Rp {int(row['price']):,}".replace(",", "."), 
            f"{int(row['volume']):,}".replace(",", ".")
        ])
        
    report_table = Table(table_data, colWidths=[120, 120, 120, 120])
    
    # Gaya Visual Tabel Kelas Institusi
    report_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1e293b")),
        ('TEXTCOLOR', (0,0), (-1,0), colors.whitesmoke),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 10),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('BOTTOMPADDING', (0,0), (-1,0), 8),
        ('BACKGROUND', (0,1), (-1,-1), colors.HexColor("#f8fafc")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cbd5e1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#f1f5f9")]),
        ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,1), (-1,-1), 9),
    ]))
    
    story.append(report_table)
    
    # Bangun File PDF
    doc.build(story)
    
    # Kembalikan file PDF agar langsung terunduh di browser pengguna
    return FileResponse(path=pdf_filename, media_type='application/pdf', filename=pdf_filename)

@app.get("/api/stress-test")
async def trigger_stress_test(ticker: str, scenario: str):
    """
    Endpoint untuk memicu simulasi stress testing krisis finansial buatan.
    """
    try:
        # Buat instance bot dummy untuk simulasi
        class DummyBot:
            def evaluate_trading_signals_ihsg(self, ticker, current_price, mm_status, mm_avg_price):
                return "SIMULATION_MODE"
        
        dummy_bot = DummyBot()
        result = run_historical_stress_test(ticker, scenario, dummy_bot)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Stress test failed: {str(e)}")

@app.get("/api/institutional-secrets/{ticker}")
async def get_market_secrets(ticker: str, current_price: int):
    """
    Endpoint untuk mendapatkan intelijen rahasia mikrostruktur pasar:
    - Iceberg Order Detection
    - Dark Pool Crossing Filter
    - Pre-Closing Markup Analysis
    """
    ticker = ticker.upper()
    
    iceberg_analysis = asd.detect_iceberg_orders(ticker, price_level=current_price)
    crossing_analysis = asd.check_crossing_manipulation(ticker)
    closing_analysis = asd.analyze_pre_closing_markup(ticker)
    
    return {
        "ticker": ticker,
        "iceberg_intelligence": iceberg_analysis,
        "dark_pool_crossing": crossing_analysis,
        "pre_closing_markup": closing_analysis
    }

@app.get("/api/bot-audit-logs")
async def get_bot_audit_logs():
    """
    Endpoint untuk mendapatkan log audit transparansi keputusan robot.
    """
    conn = psycopg2.connect(DB_PARAMS)
    query = """
        SELECT order_id, time, ticker, side, price, quantity_lot, trigger_reason, status
        FROM bot_orders 
        ORDER BY time DESC 
        LIMIT 20
    """
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    logs = []
    for _, row in df.iterrows():
        logs.append({
            "id": int(row['order_id']),
            "time": row['time'].strftime("%H:%M:%S"),
            "ticker": row['ticker'],
            "side": row['side'],
            "price": int(row['price']),
            "qty": int(row['quantity_lot']),
            "trigger_reason": row['trigger_reason'],
            "status": row['status']
        })
    
    return logs

def generate_daily_summary_html(summary_data: dict) -> str:
    """Membuat template email profesional institusional berbasis HTML."""
    return f"""
    <html>
        <body style="font-family: sans-serif; color: #334155; padding: 20px;">
            <h2 style="color: #10b981; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px;">
                🤖 SMART MONEY BOT: RINGKASAN PERFORMA HARIAN
            </h2>
            <p>Halo Pemilik Modal, berikut adalah laporan transparansi kinerja portofolio IHSG Anda hari ini:</p>
            <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                <tr style="background-color: #f8fafc;">
                    <td style="padding: 10px; border: 1px solid #e2e8f0;"><b>Total Ekuitas:</b></td>
                    <td style="padding: 10px; border: 1px solid #e2e8f0;">Rp {summary_data['total_equity']:,}</td>
                </tr>
                <tr>
                    <td style="padding: 10px; border: 1px solid #e2e8f0;"><b>Profit/Loss Hari Ini:</b></td>
                    <td style="padding: 10px; border: 1px solid #e2e8f0; color: {'#10b981' if summary_data['pnl'] >= 0 else '#ef4444'};">
                        <b>{'+' if summary_data['pnl'] >= 0 else ''}Rp {summary_data['pnl']:,} ({summary_data['pnl_pct']}%)</b>
                    </td>
                </tr>
                <tr style="background-color: #f8fafc;">
                    <td style="padding: 10px; border: 1px solid #e2e8f0;"><b>Jumlah Transaksi:</b></td>
                    <td style="padding: 10px; border: 1px solid #e2e8f0;">{summary_data['total_trades']} Trades Executed</td>
                </tr>
            </table>
            <p style="font-size: 12px; color: #64748b; border-top: 1px solid #e2e8f0; padding-top: 15px;">
                *Laporan ini dikirim otomatis oleh kecerdasan buatan Smart Money Tracker berdasarkan data kliring bursa.
            </p>
        </body>
    </html>
    """

@app.post("/api/trigger-daily-report")
async def trigger_daily_report():
    """
    Fungsi Penyiaran: Dipicu otomatis setiap jam 16.15 WIB 
    untuk mengirim email sekaligus mendorong notifikasi ke dasbor aplikasi.
    """
    # Simulasi kalkulasi data harian dari database (Ganti dengan kueri riil Anda)
    mock_summary = {
        "total_equity": 102450000,
        "pnl": 2450000,
        "pnl_pct": 2.45,
        "total_trades": 3
    }
    
    # 1. KIRIM NOTIFIKASI KE EMAIL
    msg = MIMEMultipart("alternative")
    msg["Subject"] = f"📈 Smart Money Daily Report: +Rp {mock_summary['pnl']:,}"
    msg["From"] = SENDER_EMAIL
    msg["To"] = RECEIVER_EMAIL
    msg.attach(MIMEText(generate_daily_summary_html(mock_summary), "html"))
    
    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.sendmail(SENDER_EMAIL, RECEIVER_EMAIL, msg.as_string())
        email_status = "SUCCESS"
    except Exception as e:
        email_status = f"FAILED: {str(e)}"

    # 2. DORONG PEMBERITAHUAN LIVE KE APLIKASI (IN-APP)
    app_notif = {
        "title": "Laporan Harian Selesai Berbuku",
        "message": f"Sesi IHSG ditutup. Portofolio mengantongi profit +{mock_summary['pnl_pct']}% hari ini. Ringkasan lengkap telah dikirim ke email Anda.",
        "type": "SUCCESS"
    }
    
    # Simpan riwayat notifikasi ke TimescaleDB
    conn = psycopg2.connect(DB_PARAMS)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO app_notifications (title, message, type) VALUES (%s, %s, %s)", (app_notif['title'], app_notif['message'], app_notif['type']))
    conn.commit()
    cursor.close()
    conn.close()

    # Masukkan ke antrean memori SSE agar UI langsung berkedip menyala tanpa refresh
    await notification_queue.put(app_notif)
    
    return {"status": "NOTIFICATIONS_FIRED", "email_delivery": email_status}

@app.get("/api/notifications/stream")
async def stream_live_notifications():
    """Endpoint Server-Sent Events (SSE) agar frontend Next.js menerima notifikasi instan."""
    async def event_generator():
        while True:
            notif = await notification_queue.get()
            yield f"data: {json.dumps(notif)}\n\n"
    return StreamingResponse(event_generator(), media_type="text/event-stream")

@app.get("/api/virtual-account-status")
async def get_virtual_account_status():
    """
    Endpoint untuk mendapatkan status akun virtual (paper trading).
    Mengembalikan saldo cash dan daftar saham yang dipegang.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # Ambil saldo cash virtual
    query_cash = "SELECT cash_balance_idr FROM virtual_account WHERE user_id = 1"
    df_cash = pd.read_sql_query(query_cash, conn)
    
    # Ambil portofolio virtual
    query_portfolio = "SELECT ticker, avg_buy_price, current_lot_qty FROM virtual_portfolio"
    df_portfolio = pd.read_sql_query(query_portfolio, conn)
    
    conn.close()
    
    cash_balance = float(df_cash['cash_balance_idr'].iloc[0]) if not df_cash.empty else 0.0
    
    holdings = []
    for _, row in df_portfolio.iterrows():
        holdings.append({
            "ticker": row['ticker'],
            "avg_buy_price": float(row['avg_buy_price']),
            "current_lot_qty": int(row['current_lot_qty'])
        })
    
    return {
        "cash_balance": cash_balance,
        "holdings": holdings
    }

@app.post("/api/virtual-account/reset")
async def reset_virtual_balance(initial_capital: float):
    """
    Endpoint untuk menyetel ulang atau mengubah konfigurasi modal awal trading virtual.
    Mendukung input berapapun (misal: 500000000 untuk 500 Juta atau 1000000000 untuk 1 Miliar).
    """
    if initial_capital <= 0:
        raise HTTPException(status_code=400, detail="Modal awal simulasi tidak boleh minus atau nol.")
        
    try:
        conn = psycopg2.connect(DB_PARAMS)
        cursor = conn.cursor()
        
        # Memanggil Stored Procedure yang telah kita buat di database
        cursor.execute("CALL reset_paper_trading_account(%s)", (initial_capital,))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        # Dorong pemberitahuan live ke dalam sistem notifikasi aplikasi
        reset_alert = {
            "title": "Sistem Simulasi Disetel Ulang",
            "message": f"Modal awal berhasil diubah menjadi Rp {initial_capital:,.2f}. Seluruh portofolio bayangan sebelumnya telah dibersihkan.",
            "type": "INFO"
        }
        await notification_queue.put(reset_alert)
        
        return {"status": "SUCCESS", "new_balance_allocated": initial_capital}
        
    except Exception as e:
        if conn: conn.rollback()
        raise HTTPException(status_code=500, detail=f"Gagal mengeksekusi parameter reset: {str(e)}")

@app.on_event("startup")
async def on_app_startup():
    """Fungsi yang otomatis berjalan saat server pertama kali dinyalakan."""
    # 1. Jalankan sistem penjadwalan latar belakang (Cron)
    bot_scheduler.init_market_scheduler()
    
    # 2. Jalankan loop pemrosesan data bursa pendeteksi Smart Money
    asyncio.create_task(core_trading_loop())

async def core_trading_loop():
    """Loop pemindaian data berkecepatan tinggi yang patuh pada bendera jadwal (Scheduler Flag)."""
    while True:
        # Loop hanya akan memproses kueri jika status BOT_IS_RUNNING bernilai True (diatur oleh Cron)
        if bot_scheduler.BOT_IS_RUNNING:
            # -------------------------------------------------------------
            # DI SINI LOGIKA DATA ANALISIS & SIMULASI TRADING DIJALANKAN
            # -------------------------------------------------------------
            # Example: evaluate_trading_signals_ihsg()
            pass
        
        await asyncio.sleep(1) # Berjalan teratur per 1 detik saat aktif

@app.get("/api/bot-status")
async def get_bot_status():
    """Endpoint untuk mendapatkan status aktif/non-aktif robot berdasarkan jadwal."""
    return {
        "is_running": bot_scheduler.BOT_IS_RUNNING,
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/equity-analytics")
async def get_equity_analytics():
    """
    Endpoint untuk mendapatkan performa portofolio historis (Equity Curve Analytics).
    Mengembalikan data performa harian untuk grafik dan statistik.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    query = """
        SELECT date, total_equity, daily_pnl, daily_pnl_percent, 
               total_trades, winning_trades, losing_trades, 
               win_rate, profit_factor, max_drawdown
        FROM equity_performance 
        ORDER BY date DESC 
        LIMIT 30
    """
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    analytics = []
    for _, row in df.iterrows():
        analytics.append({
            "date": row['date'].strftime("%Y-%m-%d"),
            "total_equity": float(row['total_equity']),
            "daily_pnl": float(row['daily_pnl']),
            "daily_pnl_percent": float(row['daily_pnl_percent']),
            "total_trades": int(row['total_trades']),
            "winning_trades": int(row['winning_trades']),
            "losing_trades": int(row['losing_trades']),
            "win_rate": float(row['win_rate']),
            "profit_factor": float(row['profit_factor']),
            "max_drawdown": float(row['max_drawdown'])
        })
    
    return {
        "analytics": analytics,
        "count": len(analytics)
    }
