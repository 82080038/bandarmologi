import psycopg2
import pandas as pd

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

def check_daily_circuit_breaker(total_equity: float) -> bool:
    """
    Rem Darurat: Memeriksa apakah kerugian hari ini sudah melewati batas maksimal -2%.
    Jika YA, kunci seluruh aktivitas trading untuk melindungi sisa modal.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # Hitung total realisasi kerugian (P&L) dari transaksi yang ditutup hari ini
    # Perbaikan: Hitung P&L berdasarkan harga jual vs harga beli rata-rata saat transaksi
    query = """
        SELECT SUM(
            CASE 
                WHEN side = 'SELL' THEN 
                    (price - (SELECT avg_buy_price FROM virtual_portfolio WHERE ticker = o.ticker)) * quantity_lot * 100
                ELSE 0
            END
        ) as realized_pnl
        FROM bot_orders o
        WHERE o.side = 'SELL' 
          AND o.time::date = CURRENT_DATE 
          AND o.status = 'FILLED'
          AND EXISTS (SELECT 1 FROM virtual_portfolio WHERE ticker = o.ticker)
    """
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    realized_pnl = df['realized_pnl'].fillna(0).iloc[0]
    
    # Hitung batas maksimal kerugian toleransi (2% dari total modal)
    max_allowed_loss = total_equity * -0.02
    
    if realized_pnl <= max_allowed_loss:
        print(f"[🚨 CIRCUIT BREAKER TRIPPED] Kerugian hari ini (Rp {realized_pnl:,.2f}) telah melewati batas aman 2%. BOT DIKUNCI!")
        return True # STATUS: BAHAYA, KUNCI BOT
    return False # STATUS: AMAN, SILAHKAN TRADING

def calculate_dynamic_lot_size(total_equity: float, current_price: int, atr_value: float) -> int:
    """
    Manajemen Posisi Dinamis: Menghitung jumlah lot yang boleh dibeli
    berdasarkan tingkat volatilitas (ATR) saham saat ini.
    """
    if atr_value <= 0:
        return 1 # Default aman jika data ATR belum terbentuk
        
    # Kita hanya toleransi rugi maksimal 0.5% dari total modal untuk SATU transaksi ini
    risk_per_trade_idr = total_equity * 0.005
    
    # Rumus ukuran posisi berbasis risiko volatilitas
    target_lot = int(risk_per_trade_idr / (atr_value * 100))
    
    # Batasan tambahan: Nilai pembelian tidak boleh melebihi plafon diversifikasi (20% modal)
    max_cash_allocation = total_equity * 0.20
    max_lot_by_cash = int(max_cash_allocation / (current_price * 100))
    
    # Ambil nilai lot terkecil demi prinsip kehati-hatian (Prudence Principle)
    final_lot = min(target_lot, max_lot_by_cash)
    return max(1, final_lot) # Minimal membeli 1 lot
