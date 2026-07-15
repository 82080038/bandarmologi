#!/usr/bin/env python3
"""
Data Preparation Script for Smart Money Tracker
Mengambil data awal dari yfinance dengan rate limiter untuk menghindari pembatasan
"""

import yfinance as yf
import pandas as pd
import psycopg2
from psycopg2 import sql
from datetime import datetime, timedelta
import time
from ratelimit import limits, sleep_and_retry
import logging
import numpy as np

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Database connection
DB_CONFIG = {
    "dbname": "smart_money",
    "user": "postgres",
    "password": "secret",
    "host": "localhost",
    "port": "5432"
}

# Rate limiter configuration untuk yfinance
# yfinance memiliki rate limit sekitar 2000 requests per hour
# Kita gunakan rate limiter yang lebih konservatif
CALLS_PER_MINUTE = 30  # Konservatif untuk menghindari rate limit
ONE_MINUTE = 60

@sleep_and_retry
@limits(calls=CALLS_PER_MINUTE, period=ONE_MINUTE)
def fetch_stock_data_with_rate_limit(ticker, period="1mo"):
    """
    Mengambil data saham dengan rate limiter
    """
    try:
        logger.info(f"Fetching data for {ticker}...")
        stock = yf.Ticker(ticker)
        data = stock.history(period=period)
        time.sleep(2)  # Additional delay untuk safety
        return data
    except Exception as e:
        logger.error(f"Error fetching data for {ticker}: {e}")
        return None

def get_db_connection():
    """Membuat koneksi ke database"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        logger.error(f"Database connection error: {e}")
        return None

def insert_market_trades(conn, ticker, data):
    """Insert data market trades ke database (sesuai schema)"""
    if data is None or data.empty:
        logger.warning(f"No data to insert for {ticker}")
        return
    
    try:
        cursor = conn.cursor()
        
        for index, row in data.iterrows():
            timestamp = index
            price = float(row['Close']) if pd.notna(row['Close']) else 0.0
            volume = int(row['Volume']) if pd.notna(row['Volume']) else 0
            
            # Simulasi broker data
            buyer_broker = "BBRI" if volume > 100000 else "BBCA"
            seller_broker = "BBNI" if volume > 100000 else "BMRI"
            trade_type = "HAKA" if price > row['Open'] else "HAKI"
            
            query = sql.SQL("""
                INSERT INTO market_trades (ticker, time, price, volume, buyer_broker, seller_broker, trade_type)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """)
            
            cursor.execute(query, (ticker, timestamp, price, volume, buyer_broker, seller_broker, trade_type))
        
        conn.commit()
        logger.info(f"Inserted {len(data)} records for {ticker}")
        cursor.close()
        
    except Exception as e:
        logger.error(f"Error inserting data for {ticker}: {e}")
        conn.rollback()

def insert_order_book_snapshot(conn, ticker):
    """Insert order book snapshot simulasi (sesuai schema)"""
    try:
        cursor = conn.cursor()
        
        # Simulasi order book data
        timestamp = datetime.now()
        
        # Bids (buy orders)
        for i in range(5):
            price = 1000 - (i * 10)
            total_volume_lot = 1000 + (i * 100)
            queue_count = 5 + i
            query = sql.SQL("""
                INSERT INTO order_book_snapshots (ticker, time, price, type, total_volume_lot, queue_count)
                VALUES (%s, %s, %s, %s, %s, %s)
            """)
            cursor.execute(query, (ticker, timestamp, price, 'BID', total_volume_lot, queue_count))
        
        # Asks (sell orders)
        for i in range(5):
            price = 1000 + (i * 10)
            total_volume_lot = 1000 + (i * 100)
            queue_count = 5 + i
            query = sql.SQL("""
                INSERT INTO order_book_snapshots (ticker, time, price, type, total_volume_lot, queue_count)
                VALUES (%s, %s, %s, %s, %s, %s)
            """)
            cursor.execute(query, (ticker, timestamp, price, 'ASK', total_volume_lot, queue_count))
        
        conn.commit()
        logger.info(f"Inserted order book snapshot for {ticker}")
        cursor.close()
        
    except Exception as e:
        logger.error(f"Error inserting order book for {ticker}: {e}")
        conn.rollback()

def insert_global_sentiment(conn):
    """Insert global sentiment data (sesuai schema)"""
    try:
        cursor = conn.cursor()
        
        timestamp = datetime.now()
        
        # Insert multiple indices
        indices = [
            ('SP500', 5450.0, 0.45),
            ('NASDAQ', 19120.0, -0.12),
            ('DXY', 101.5, 0.05),
            ('COMPOSITE', 7200.0, 0.25)
        ]
        
        for index_name, last_price, daily_change_percent in indices:
            query = sql.SQL("""
                INSERT INTO global_sentiment (time, index_name, last_price, daily_change_percent)
                VALUES (%s, %s, %s, %s)
            """)
            cursor.execute(query, (timestamp, index_name, last_price, daily_change_percent))
        
        conn.commit()
        logger.info("Inserted global sentiment data")
        cursor.close()
        
    except Exception as e:
        logger.error(f"Error inserting global sentiment: {e}")
        conn.rollback()

def insert_foreign_flow(conn):
    """Insert foreign flow data (sesuai schema)"""
    try:
        cursor = conn.cursor()
        
        timestamp = datetime.now()
        
        # Insert foreign flow untuk beberapa ticker
        tickers = ['BBCA', 'BBRI', 'BMRI', 'TLKM', 'ASII']
        
        for ticker in tickers:
            foreign_buy_volume = 1000000 + hash(ticker) % 500000
            foreign_sell_volume = 800000 + hash(ticker) % 400000
            net_foreign_val_idr = (foreign_buy_volume - foreign_sell_volume) * 1000
            
            query = sql.SQL("""
                INSERT INTO foreign_flow_ihsg (time, ticker, foreign_buy_volume, foreign_sell_volume, net_foreign_val_idr)
                VALUES (%s, %s, %s, %s, %s)
            """)
            cursor.execute(query, (timestamp, ticker, foreign_buy_volume, foreign_sell_volume, net_foreign_val_idr))
        
        conn.commit()
        logger.info("Inserted foreign flow data")
        cursor.close()
        
    except Exception as e:
        logger.error(f"Error inserting foreign flow: {e}")
        conn.rollback()

def generate_simulated_stock_data(ticker, days=30, trades_per_day=20):
    """Generate simulated stock data untuk testing dengan multiple trades per hari"""
    import numpy as np
    
    dates = pd.date_range(end=datetime.now(), periods=days, freq='D')
    dates = dates[dates.weekday < 5]  # Hanya hari kerja
    
    data = []
    base_price = 1000 + hash(ticker) % 5000  # Harga base berbeda per ticker
    prev_close = base_price
    
    for i, date in enumerate(dates):
        # Generate multiple trades per hari untuk simulasi real-time
        for trade_num in range(trades_per_day):
            # Random walk untuk simulasi harga
            open_price = prev_close
            
            # Random movement (lebih kecil per trade)
            change_percent = np.random.normal(0, 0.002)  # 0.2% volatility per trade
            close_price = open_price * (1 + change_percent)
            high_price = max(open_price, close_price) * (1 + abs(np.random.normal(0, 0.005)))
            low_price = min(open_price, close_price) * (1 - abs(np.random.normal(0, 0.005)))
            volume = int(np.random.normal(50000, 10000))  # Rata-rata 50K shares per trade
            
            # Timestamp dengan intra-day granularity
            trade_time = date + pd.Timedelta(hours=9 + trade_num, minutes=np.random.randint(0, 60))
            
            data.append({
                'Open': open_price,
                'High': high_price,
                'Low': low_price,
                'Close': close_price,
                'Volume': volume
            })
            
            prev_close = close_price
    
    df = pd.DataFrame(data, index=[d['Open'] for d in data])  # Will be replaced with proper timestamps
    # Generate proper timestamps
    timestamps = []
    current_date = datetime.now()
    for i in range(len(data)):
        trade_time = current_date - pd.Timedelta(days=len(data)//trades_per_day - i//trades_per_day, 
                                                  hours=9 + (i % trades_per_day), 
                                                  minutes=np.random.randint(0, 60))
        timestamps.append(trade_time)
    
    df.index = timestamps
    return df

def insert_realtime_order_book_snapshots(conn, ticker, num_snapshots=100):
    """Insert real-time order book snapshots untuk spoofing detection"""
    try:
        cursor = conn.cursor()
        
        base_price = 1000 + hash(ticker) % 5000
        
        for i in range(num_snapshots):
            # Generate snapshots dengan interval 1-3 detik
            timestamp = datetime.now() - pd.Timedelta(seconds=num_snapshots - i)
            
            # Bids (buy orders) dengan variasi volume untuk simulasi spoofing
            for j in range(5):
                price = base_price - (j * 10)
                # Simulasi spoofing: volume besar yang tiba-tiba hilang
                if i > 50 and j == 0:  # Spoofing scenario di snapshot kedua
                    total_volume_lot = 50000 + np.random.randint(0, 10000)
                else:
                    total_volume_lot = 1000 + (j * 100) + np.random.randint(0, 500)
                queue_count = 5 + j
                
                query = sql.SQL("""
                    INSERT INTO order_book_snapshots (ticker, time, price, type, total_volume_lot, queue_count)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """)
                cursor.execute(query, (ticker, timestamp, price, 'BID', total_volume_lot, queue_count))
            
            # Asks (sell orders)
            for j in range(5):
                price = base_price + (j * 10)
                total_volume_lot = 1000 + (j * 100) + np.random.randint(0, 500)
                queue_count = 5 + j
                
                query = sql.SQL("""
                    INSERT INTO order_book_snapshots (ticker, time, price, type, total_volume_lot, queue_count)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """)
                cursor.execute(query, (ticker, timestamp, price, 'ASK', total_volume_lot, queue_count))
        
        conn.commit()
        logger.info(f"Inserted {num_snapshots} real-time order book snapshots for {ticker}")
        cursor.close()
        
    except Exception as e:
        logger.error(f"Error inserting real-time order book for {ticker}: {e}")
        conn.rollback()

def insert_stress_test_scenarios(conn):
    """Insert additional stress test scenarios"""
    try:
        cursor = conn.cursor()
        
        scenarios = [
            ('TECH_BUBBLE_BURST', 0.70, 0.85, 8),  # Tech bubble crash
            ('COVID_MARKET_CRASH', 0.60, 0.90, 10),  # COVID-style crash
            ('FLASH_CRASH_EVENT', 0.80, 0.95, 15),  # Flash crash
            ('LIQUIDITY_CRISIS', 0.90, 0.60, 5),  # Liquidity drain focus
        ]
        
        for scenario_name, price_drop, liquidity_drain, volume_spike in scenarios:
            # Check if scenario exists first
            check_query = sql.SQL("SELECT scenario_id FROM stress_test_scenarios WHERE scenario_name = %s")
            cursor.execute(check_query, (scenario_name,))
            exists = cursor.fetchone()
            
            if exists:
                # Update existing
                update_query = sql.SQL("""
                    UPDATE stress_test_scenarios 
                    SET price_drop_multiplier = %s, liquidity_drain_ratio = %s, volume_spike_multiplier = %s
                    WHERE scenario_name = %s
                """)
                cursor.execute(update_query, (price_drop, liquidity_drain, volume_spike, scenario_name))
            else:
                # Insert new
                insert_query = sql.SQL("""
                    INSERT INTO stress_test_scenarios (scenario_name, price_drop_multiplier, liquidity_drain_ratio, volume_spike_multiplier)
                    VALUES (%s, %s, %s, %s)
                """)
                cursor.execute(insert_query, (scenario_name, price_drop, liquidity_drain, volume_spike))
        
        conn.commit()
        logger.info("Inserted additional stress test scenarios")
        cursor.close()
        
    except Exception as e:
        logger.error(f"Error inserting stress test scenarios: {e}")
        conn.rollback()

def main():
    """Main function untuk data preparation"""
    logger.info("Starting comprehensive data preparation...")
    
    # Ticker saham untuk testing (tanpa .JK karena yfinance tidak support Indonesia)
    tickers = [
        "BBCA",  # Bank Central Asia (simulasi)
        "BBRI",  # Bank Rakyat Indonesia (simulasi)
        "BMRI",  # Bank Mandiri (simulasi)
        "TLKM",  # Telkom Indonesia (simulasi)
        "ASII",  # Astra International (simulasi)
    ]
    
    # Connect ke database
    conn = get_db_connection()
    if not conn:
        logger.error("Failed to connect to database")
        return
    
    try:
        # Insert global sentiment dan foreign flow
        logger.info("Inserting global market data...")
        insert_global_sentiment(conn)
        insert_foreign_flow(conn)
        
        # Insert additional stress test scenarios
        logger.info("Inserting stress test scenarios...")
        insert_stress_test_scenarios(conn)
        
        # Generate dan insert data untuk setiap ticker
        for ticker in tickers:
            logger.info(f"Processing {ticker}...")
            
            # Generate simulated data dengan 500+ records untuk VWAP calculation
            # 25 hari kerja × 20 trades per hari = 500 records
            logger.info(f"Generating comprehensive data for {ticker} (500+ records)...")
            data = generate_simulated_stock_data(ticker, days=25, trades_per_day=20)
            
            if data is not None and not data.empty:
                # Insert ke database
                insert_market_trades(conn, ticker, data)
                
                # Insert real-time order book snapshots untuk spoofing detection
                logger.info(f"Generating real-time order book snapshots for {ticker}...")
                insert_realtime_order_book_snapshots(conn, ticker, num_snapshots=100)
                
                logger.info(f"Successfully inserted comprehensive data for {ticker}: {len(data)} trades")
            else:
                logger.warning(f"No data generated for {ticker}")
        
        logger.info("Comprehensive data preparation completed successfully!")
        
    except Exception as e:
        logger.error(f"Error in main process: {e}")
    finally:
        conn.close()
        logger.info("Database connection closed")

if __name__ == "__main__":
    main()
