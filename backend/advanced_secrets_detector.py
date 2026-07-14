import psycopg2
import pandas as pd
from datetime import datetime, time

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

# =====================================================================
# RAHASIA 1: ICEBERG ORDER DETECTOR
# =====================================================================
def detect_iceberg_orders(ticker: str, price_level: int, time_window_seconds: int = 5) -> dict:
    """
    Membongkar Iceberg Order:
    Mendeteksi jika total volume yang ditransaksikan (Matched) di satu harga jauh melebihi
    kapasitas visual antrean Bid/Ask asli yang tertera di Order Book pada detik yang sama.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # 1. Hitung total transaksi sukses di harga tersebut dalam jendela waktu sempit
    query_trades = """
        SELECT SUM(volume) as total_matched_vol 
        FROM market_trades 
        WHERE ticker = %s AND price = %s AND time >= NOW() - INTERVAL '%s second'
    """
    df_trades = pd.read_sql_query(query_trades, conn, params=(ticker.upper(), price_level, time_window_seconds))
    
    # 2. Ambil snapshot kapasitas visual order book di harga tersebut
    query_ob = """
        SELECT total_volume_lot 
        FROM order_book_snapshots 
        WHERE ticker = %s AND price = %s 
        ORDER BY time DESC LIMIT 1
    """
    df_ob = pd.read_sql_query(query_ob, conn, params=(ticker.upper(), price_level))
    conn.close()
    
    total_matched = df_trades['total_matched_vol'].fillna(0).iloc[0]
    visible_queue = df_ob['total_volume_lot'].fillna(0).iloc[0]
    
    # Logika Matematika Kuantitatif: 
    # Jika transaksi sukses > 4x lipat dari antrean yang terlihat, berarti ada isi ulang otomatis (Iceberg)
    if visible_queue > 0 and total_matched > (visible_queue * 4):
        return {
            "status": "ICEBERG_DETECTED",
            "price": price_level,
            "visible_lot": int(visible_queue),
            "actual_executed_lot": int(total_matched),
            "multiplier": round(total_matched / visible_queue, 1)
        }
    return {"status": "NORMAL"}

# =====================================================================
# RAHASIA 2: NEGOTIATED MARKET FILTER (CROSSING SAHAM)
# =====================================================================
def check_crossing_manipulation(ticker: str) -> dict:
    """
    Menyaring Sentimen Palsu:
    Mendeteksi pemindahan barang raksasa di Pasar Negosiasi yang sering digunakan
    untuk memicu kepanikan (Panic Selling) ritel di Pasar Reguler.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # Ambil transaksi pasar reguler terakhir
    query_reg = "SELECT price FROM market_trades WHERE ticker = %s ORDER BY time DESC LIMIT 1"
    df_reg = pd.read_sql_query(query_reg, conn, params=(ticker.upper(),))
    
    # Ambil transaksi pasar negosiasi dalam 10 menit terakhir
    query_neg = """
        SELECT price, SUM(volume) as total_neg_vol, SUM(total_value_idr) as total_val
        FROM negotiated_market_trades 
        WHERE ticker = %s AND time >= NOW() - INTERVAL '10 minute'
        GROUP BY price
    """
    df_neg = pd.read_sql_query(query_neg, conn, params=(ticker.upper(),))
    conn.close()
    
    if df_reg.empty or df_neg.empty:
        return {"manipulation_risk": "LOW"}
        
    reg_price = float(df_reg['price'].iloc[0])
    neg_price = float(df_neg['price'].iloc[0])
    total_value = int(df_neg['total_val'].iloc[0])
    
    # Jika harga negosiasi diskon > 5% dibanding harga pasar reguler dengan nilai transaksi di atas 5 Miliar Rupiah
    price_discount = ((reg_price - neg_price) / reg_price) * 100
    if price_discount > 5.0 and total_value > 5_000_000_000:
        return {
            "manipulation_risk": "HIGH",
            "reason": f"Crossing saham skala besar terdeteksi di harga Rp {neg_price} (Diskon {round(price_discount, 1)}%).",
            "instruction": "ABAIKAN jika grafik pasar reguler mendadak drop, ini adalah panic-selling buatan."
        }
    return {"manipulation_risk": "LOW"}

# =====================================================================
# RAHASIA 3: PRE-CLOSING MANIPULATION ANALYZER
# =====================================================================
def analyze_pre_closing_markup(ticker: str) -> dict:
    """
    Membongkar Taktik 'Painting the Closed Curtain':
    Membandingkan volume 10 menit terakhir (15.50 - 16.00 WIB) dengan 
    rata-rata volume sesi reguler sepanjang hari.
    """
    current_time = datetime.now().time()
    
    # Analisis ini hanya valid dijalankan menjelang atau setelah pasar tutup (di atas pukul 15.55 WIB)
    if current_time < time(15, 55):
        return {"status": "WAITING_FOR_PRE_CLOSING_SESSION"}
        
    conn = psycopg2.connect(DB_PARAMS)
    
    # 1. Hitung volume akumulasi di sesi pre-closing (15.50 - 16.00)
    query_closing = """
        SELECT SUM(volume) as closing_vol, AVG(price) as closing_avg_price
        FROM market_trades 
        WHERE ticker = %s AND time::time BETWEEN '15:50:00' AND '16:00:00' AND time::date = CURRENT_DATE
    """
    df_closing = pd.read_sql_query(query_closing, conn, params=(ticker.upper(),))
    
    # 2. Hitung rata-rata volume per 10 menit dari jam 09.00 - 15.50
    query_regular = """
        SELECT SUM(volume) / 41 as avg_10min_volume -- 41 adalah estimasi blok 10-menitan sesi reguler IHSG
        FROM market_trades 
        WHERE ticker = %s AND time::time BETWEEN '09:00:00' AND '15:50:00' AND time::date = CURRENT_DATE
    """
    df_regular = pd.read_sql_query(query_regular, conn, params=(ticker.upper(),))
    conn.close()
    
    closing_vol = df_closing['closing_vol'].fillna(0).iloc[0]
    avg_reg_vol = df_regular['avg_10min_volume'].fillna(1).iloc[0]
    
    # Hitung rasio lonjakan volume
    volume_surge_ratio = closing_vol / avg_reg_vol
    
    # Jika volume pre-closing melonjak di atas 4x rata-rata harian, tandai manipulasi kosmetik grafik
    if volume_surge_ratio > 4.0:
        return {
            "status": "MANIPULATION_DETECTED",
            "type": "PAINTING_THE_CURTAIN_MARKUP",
            "volume_surge_factor": round(volume_surge_ratio, 1),
            "action_plan": "Jangan FOMO ikut beli di akhir hari. Tunggu aksi gap-down esok pagi jam 09.00 WIB."
        }
        
    return {"status": "NORMAL_CLOSING"}
