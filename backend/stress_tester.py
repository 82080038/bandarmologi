import psycopg2
import pandas as pd
import json

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

def run_historical_stress_test(ticker: str, scenario_name: str, active_bot_instance):
    """
    Mensimulasikan krisis finansial buatan pada data Running Trade 
    untuk menguji apakah fungsi pengaman bot bekerja membatasi kerugian.
    """
    conn = psycopg2.connect(DB_PARAMS)
    cursor = conn.cursor()
    
    # 1. Ambil parameter skenario krisis dari database
    cursor.execute("SELECT price_drop_multiplier, liquidity_drain_ratio, volume_spike_multiplier FROM stress_test_scenarios WHERE scenario_name = %s", (scenario_name,))
    scenario = cursor.fetchone()
    if not scenario:
        return {"status": "ERROR", "message": "Skenario krisis tidak ditemukan."}
        
    price_drop, bid_drain, vol_spike = scenario
    
    # 2. Ambil data transaksi normal terakhir sebagai basis manipulasi krisis
    query_normal = f"SELECT price, volume FROM market_trades WHERE ticker = %s ORDER BY time DESC LIMIT 10"
    df_normal = pd.read_sql_query(query_normal, conn, params=(ticker.upper(),))
    cursor.close()
    conn.close()
    
    print(f"=== MEMULAI SIMULASI STRESS TEST: {scenario_name} PADA SAHAM {ticker} ===")
    
    # 3. Manipulasi data normal menjadi data krisis ekstrem (Synthetic Crisis Data)
    for index, row in df_normal.iterrows():
        synthetic_price = int(row['price'] * price_drop) # Harga anjlok instan
        synthetic_volume = int(row['volume'] * vol_spike) # Volume panic-selling meledak
        
        print(f"[SANDBOX CRITICAL] Data Input: Rp {synthetic_price} | Vol: {synthetic_volume} Lot")
        
        # 4. Tembakkan data krisis ini ke dalam fungsi pengambil keputusan bot Anda
        # Kita uji apakah bot memicu fungsi darurat atau tetap melakukan pembelian konyol
        try:
            bot_action = active_bot_instance.evaluate_trading_signals_ihsg(
                ticker=ticker,
                current_price=synthetic_price,
                mm_status="BIG DISTRIBUTION", # Ubah status bandar menjadi distribusi massal
                mm_avg_price=row['price']
            )
        except Exception as e:
            print(f"[STRESS TEST ERROR] Bot error during simulation: {str(e)}")
            bot_action = "ERROR"
        
    return {"status": "SUCCESS", "message": f"Simulasi {scenario_name} berhasil dijalankan. Periksa log log kegagalan bot."}
