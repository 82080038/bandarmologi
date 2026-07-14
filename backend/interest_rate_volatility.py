import pandas as pd
import numpy as np
import psycopg2
from datetime import datetime, timedelta

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

def calculate_atr_volatility(ticker: str, period: int = 14) -> float:
    """
    Menghitung Average True Range (ATR) secara real-time dari data bursa 
    untuk mendeteksi apakah pasar saham masuk ke fase volatilitas abnormal.
    """
    conn = psycopg2.connect(DB_PARAMS)
    
    # Ambil data OHLC (Open, High, Low, Close) per menit dari TimescaleDB
    query = f"""
        SELECT 
            time_bucket('1 minute', time) AS minute,
            MAX(price) as high,
            MIN(price) as low,
            (array_agg(price ORDER BY time ASC))[1] as open,
            (array_agg(price ORDER BY time DESC))[1] as close
        FROM market_trades
        WHERE ticker = %s AND time >= NOW() - INTERVAL '1 hour'
        GROUP BY minute ORDER BY minute DESC LIMIT {period + 1};
    """
    df = pd.read_sql_query(query, conn, params=(ticker.upper(),))
    conn.close()
    
    if len(df) < period:
        return 0.0
        
    # Hitung Komponen True Range (TR)
    df['tr1'] = df['high'] - df['low']
    df['tr2'] = abs(df['high'] - df['close'].shift(-1))
    df['tr3'] = abs(df['low'] - df['close'].shift(-1))
    df['true_range'] = df[['tr1', 'tr2', 'tr3']].max(axis=1)
    
    # Hitung Nilai ATR
    atr = df['true_range'].rolling(window=period).mean().iloc[period-1]
    return float(atr)

def is_interest_rate_announcement_danger(macro_calendar_time: str) -> bool:
    """
    Fitur Ekonomi Keselamatan: Memeriksa jarak waktu saat ini dengan jam 
    rilis kebijakan suku bunga resmi.
    """
    current_time_wib = datetime.now()
    announcement_time = datetime.strptime(macro_calendar_time, "%Y-%m-%d %H:%M:%S")
    
    # Tentukan Zona Bahaya Volatilitas: 30 menit sebelum dan sesudah rilis suku bunga
    buffer_start = announcement_time - timedelta(minutes=30)
    buffer_end = announcement_time + timedelta(minutes=30)
    
    if buffer_start <= current_time_wib <= buffer_end:
        return True # STATUS: BAHAYA MAKRO AKTIF
    return False
