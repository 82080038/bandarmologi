import requests
import psycopg2
import pandas as pd
import os
import time as time_sleep
from interest_rate_volatility import calculate_atr_volatility, is_interest_rate_announcement_danger
from market_calendar import is_market_open
from portfolio_risk_shield import check_daily_circuit_breaker, calculate_dynamic_lot_size

# Konfigurasi Akses API Sekuritas (Contoh standar REST API Institusi/Sekuritas Lokal)
BROKER_API_URL = "https://sekuritas-pilihan.com"
BROKER_API_KEY = os.environ.get("BROKER_API_KEY")
BROKER_SECRET_TOKEN = os.environ.get("BROKER_SECRET_TOKEN")

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

def send_order_to_broker(ticker: str, side: str, price: int, qty_lot: int) -> dict:
    """
    Fungsi Eksekusi Jaringan: 
    Menembak langsung API Sekuritas untuk mengeksekusi Hajar Kanan (HaKa) / Hajar Kiri (HaKi).
    """
    headers = {
        "Authorization": f"Bearer {BROKER_SECRET_TOKEN}",
        "X-API-Key": BROKER_API_KEY,
        "Content-Type": "application/json"
    }
    
    payload = {
        "client_id": "ALGO_BOT_01",
        "ticker": ticker.upper(),
        "side": side.upper(),       # "BUY" atau "SELL"
        "price": price,
        "quantity_lot": qty_lot,
        "order_type": "LIMIT"       # Menggunakan Limit Order untuk presisi eksekusi
    }
    
    try:
        response = requests.post(BROKER_API_URL, json=payload, headers=headers, timeout=5)
        if response.status_code == 200:
            return response.json() # Mengembalikan data sukses order dari bursa
        else:
            return {"status": "FAILED", "reason": f"Broker HTTP {response.status_code}"}
    except Exception as e:
        return {"status": "FAILED", "reason": str(e)}

def check_global_and_foreign_sentiment(ticker: str) -> bool:
    """
    Ekonomi Aturan: Memastikan pasar global aman dan asing masuk ke IHSG 
    sebelum mengizinkan bot domestik mengeksekusi order beli.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # 1. Periksa Sentimen Wall Street (S&P 500) terakhir
    query_global = "SELECT daily_change_percent FROM global_sentiment WHERE index_name = 'SP500' ORDER BY time DESC LIMIT 1"
    df_global = pd.read_sql_query(query_global, conn)
    
    # 2. Periksa Transaksi Asing (Foreign Flow) pada saham incaran dalam 3 jam terakhir
    query_foreign = """
        SELECT SUM(net_foreign_val_idr) as net_foreign 
        FROM foreign_flow_ihsg 
        WHERE ticker = %s AND time >= NOW() - INTERVAL '3 hour'
    """
    df_foreign = pd.read_sql_query(query_foreign, conn, params=(ticker.upper(),))
    conn.close()
    
    # Logika Filter Makro
    sp500_safe = True
    if not df_global.empty:
        # Jika Wall Street minus lebih dari -1.5%, pasar global dianggap darurat/panik
        if df_global['daily_change_percent'].iloc[0] < -1.5:
            sp500_safe = False
            print(f"[MACRO FILTER] LOCK TRADING: Wall Street anjlok ({df_global['daily_change_percent'].iloc[0]}%). Risiko pasar global tinggi.")
            
    foreign_accumulating = False
    if not df_foreign.empty and df_foreign['net_foreign'].iloc[0] is not None:
        # Jika nilai net buy asing di atas 1 Miliar Rupiah
        if df_foreign['net_foreign'].iloc[0] > 1_000_000_000:
            foreign_accumulating = True
            
    # Bot hanya boleh beli jika Global Aman ATAU Asing terbukti masuk masif ke IHSG meluncurkan buying power
    return sp500_safe or foreign_accumulating

def evaluate_trading_signals_ihsg(ticker: str, current_price: int, mm_status: str, mm_avg_price: float):
    """
    Mesin Aturan Finansial (Trading Rules Engine) untuk IHSG:
    Mengevaluasi data Smart Money dengan filter Global Macro untuk mengambil tindakan eksekusi otonom.
    """
    # 1. Cek Circuit Breaker Harian (Daily Drawdown Protection)
    from virtual_paper_engine import VirtualExecutionEngine
    total_equity = VirtualExecutionEngine.get_virtual_account()
    
    if check_daily_circuit_breaker(total_equity):
        print(f"[🚨 CIRCUIT BREAKER] Trading dihentikan untuk hari ini. Batas kerugian harian terlampaui.")
        return "LOCK_REASON_DAILY_DRAWDOWN"
    
    # 2. Hitung ukuran posisi dinamis berdasarkan volatilitas (ATR)
    current_atr = calculate_atr_volatility(ticker)
    dynamic_lot_size = calculate_dynamic_lot_size(total_equity, current_price, current_atr)
    
    # Jalankan pemeriksaan gerbang global macro terlebih dahulu
    global_is_ok = check_global_and_foreign_sentiment(ticker)
    
    # ATURAN 1: Pemicu Beli (Buy Trigger)
    # Jika terjadi Akumulasi Besar dan harga saat ini berada di bawah atau sama dengan harga modal rata-rata bandar
    if mm_status == "BIG ACCUMULATION" and current_price <= (mm_avg_price * 1.01):
        if global_is_ok:
            print(f"[BOT TRADING] Sinyal VALID. Mengirim order beli {ticker} via API Sekuritas.")
            # Eksekusi Order ke API Broker dengan ukuran posisi dinamis
            response = send_order_to_broker(ticker, "BUY", current_price, dynamic_lot_size)
            # Simpan Log Eksekusi ke Database
            save_bot_log(ticker, "BUY", current_price, dynamic_lot_size, f"Big Accumulation & Price near MM Avg Cost (Global Safe) - Dynamic Lot: {dynamic_lot_size} (ATR: {current_atr})", response)
        else:
            print(f"[BOT TRADING] Sinyal BELI {ticker} DIBATALKAN otomatis oleh sistem keamanan interkoneksi global.")

    # ATURAN 2: Pemicu Jual / Stop Loss (Sell Trigger)
    # Jika bandar mulai melakukan distribusi besar, segera amankan aset modal (tanpa filter global)
    elif mm_status == "BIG DISTRIBUTION":
        print(f"[BOT TRADING] Memicu Sinyal JUAL DARURAT untuk {ticker} di harga Rp {current_price}")
        response = send_order_to_broker(ticker, "SELL", current_price, dynamic_lot_size)
        save_bot_log(ticker, "SELL", current_price, dynamic_lot_size, f"Emergency Exit: Big Distribution Detected - Dynamic Lot: {dynamic_lot_size}", response)

# Fungsi legacy untuk kompatibilitas
def evaluate_trading_signals(ticker: str, current_price: int, mm_status: str, mm_avg_price: float):
    """Wrapper legacy untuk kompatibilitas dengan kode yang ada."""
    return evaluate_trading_signals_ihsg(ticker, current_price, mm_status, mm_avg_price)

def save_bot_log(ticker: str, side: str, price: int, qty: int, reason: str, broker_res: dict):
    """Mencatat riwayat keputusan bot ke TimescaleDB."""
    conn = psycopg2.connect(DB_PARAMS)
    cursor = conn.cursor()
    
    status = "FILLED" if broker_res.get("status") == "SUCCESS" else "REJECTED"
    broker_ref = broker_res.get("order_id_ref", "NONE")
    
    cursor.execute("""
        INSERT INTO bot_orders (ticker, side, price, quantity_lot, trigger_reason, status, broker_order_ref)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (ticker, side, price, qty, reason, status, broker_ref))
    
    conn.commit()
    cursor.close()
    conn.close()

def final_safety_execution_loop(ticker: str, current_price: int, mm_status: str, mm_avg_price: float):
    """
    Penyempurnaan Proteksi Total Tingkat Akhir:
    Menggabungkan semua lapisan keamanan sebelum eksekusi trading.
    """
    # Waktu rilis keputusan suku bunga BI (Contoh input dinamis dari sistem kalender ekonomi)
    BI_RATE_RELEASE_TIME = "2026-07-15 14:00:00" 
    
    # 1. Proteksi Suku Bunga: Cek Apakah Masuk Zona Bahaya Pengumuman Moneter
    if is_interest_rate_announcement_danger(BI_RATE_RELEASE_TIME):
        print(f"[🚨 MACRO EMERGENCY] BOT LOCKED: Pengumuman Suku Bunga Sedang Berlangsung. Risiko Slippage Tinggi.")
        return "LOCK_REASON_INTEREST_RATE"
        
    # 2. Proteksi Volatilitas: Cek Apakah Lonjakan ATR Melebihi Batas Toleransi Normal (Abnormal Spike)
    current_atr = calculate_atr_volatility(ticker)
    ATR_THRESHOLD_LIMIT = 150 # Toleransi pergerakan maksimal senilai Rp 150 per menit
    if current_atr > ATR_THRESHOLD_LIMIT:
        print(f"[🚨 ATR SPIKE] BOT LOCKED: Volatilitas pasar saham {ticker} terlalu ekstrem (ATR: {current_atr}). Menghindari badai pasar.")
        return "LOCK_REASON_HIGH_VOLATILITY"
        
    # 3. Jika Semua Parameter Pengaman Lolos, Evaluasi Sinyal Trading Seperti Biasa
    evaluate_trading_signals_ihsg(ticker, current_price, mm_status, mm_avg_price)

def start_autonomous_bot_daemon():
    """Fungsi latar belakang yang berjalan tanpa henti di server."""
    print("🤖 Mengaktifkan Daemon Bot Cerdas Smart Money...")
    
    while True:
        # Pengecekan pertama: Apakah bursa saat ini buka?
        market_status, reason = is_market_open()
        
        if not market_status:
            if reason == "MARKET_BREAK_TIME":
                print("[💤 BOT SLEEP] Bursa sedang istirahat siang. Bot tidur sementara selama 30 menit.")
                time_sleep.sleep(60 * 30) # Tidur selama 30 menit, lalu cek lagi
            elif reason in ["MARKET_CLOSED_NIGHT", "MARKET_CLOSED_WEEKEND", "MARKET_CLOSED_HOLIDAY"]:
                print(f"[💤 BOT SLEEP] Bursa Tutup ({reason}). Bot mode hemat daya. Cek ulang dalam 1 jam.")
                time_sleep.sleep(60 * 60) # Tidur selama 1 jam
            continue
            
        # JIKA BURSA BUKA (SESSION_1 / SESSION_2) -> Jalankan Analisis & Eksekusi Trading
        print(f"[🚀 BOT ACTIVE] Bursa sedang berjalan aktif ({reason}). Mengeksekusi pemindaian data...")
        
        # Jalankan fungsi analisis deteksi bandarmologi yang sudah kita buat sebelumnya
        # execute_trading_logic()
        
        time_sleep.sleep(1) # Berjalan reguler per 1 detik saat bursa aktif
