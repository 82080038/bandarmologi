import psycopg2
import pandas as pd

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

class VirtualExecutionEngine:
    @staticmethod
    def get_virtual_account():
        """Membaca sisa uang tunai simulasi dari database."""
        conn = psycopg2.connect(DB_PARAMS)
        try:
            df = pd.read_sql_query("SELECT cash_balance_idr FROM virtual_account WHERE user_id = 1", conn)
            if df.empty:
                # Fallback: coba ambil user pertama yang tersedia
                df_fallback = pd.read_sql_query("SELECT cash_balance_idr FROM virtual_account ORDER BY user_id LIMIT 1", conn)
                if not df_fallback.empty:
                    return float(df_fallback['cash_balance_idr'].iloc[0])
                return 0.0
            return float(df['cash_balance_idr'].iloc[0])
        finally:
            conn.close()

    @staticmethod
    def execute_virtual_order(ticker: str, side: str, price: int, qty_lot: int, reason: str) -> dict:
        """
        Mesin Simulasi Pasar: Memproses order Beli/Jual secara instan 
        menggunakan uang virtual di database internal lokal.
        """
        ticker = ticker.upper()
        side = side.upper()
        
        # Hitung Nilai Transaksi Bersih (1 Lot = 100 Lembar)
        gross_value = price * qty_lot * 100
        
        # Biaya Transaksi Simulasi (Simulasi Brokerage Fee Institusi)
        fee_rate = 0.0015 if side == "BUY" else 0.0025
        transaction_fee = gross_value * fee_rate
        
        conn = psycopg2.connect(DB_PARAMS)
        cursor = conn.cursor()
        
        try:
            # -----------------------------------------------------------------
            # EKSEKUSI SIMULASI BELI (VIRTUAL BUY)
            # -----------------------------------------------------------------
            if side == "BUY":
                total_cost = gross_value + transaction_fee
                current_cash = VirtualExecutionEngine.get_virtual_account()
                
                if current_cash < total_cost:
                    return {"status": "REJECTED", "reason": "Saldo Virtual Cash Tidak Mencukupi."}
                
                # Potong Saldo Tunai Virtual dengan fallback user_id
                try:
                    cursor.execute("UPDATE virtual_account SET cash_balance_idr = cash_balance_idr - %s WHERE user_id = 1", (total_cost,))
                    if cursor.rowcount == 0:
                        # Fallback: update user pertama yang tersedia
                        cursor.execute("UPDATE virtual_account SET cash_balance_idr = cash_balance_idr - %s WHERE user_id = (SELECT user_id FROM virtual_account LIMIT 1)", (total_cost,))
                except Exception as e:
                    conn.rollback()
                    return {"status": "ERROR", "reason": f"Gagal update saldo virtual: {str(e)}"}
                
                # Masukkan atau perbarui barang di Portofolio Virtual
                cursor.execute("SELECT avg_buy_price, current_lot_qty FROM virtual_portfolio WHERE ticker = %s", (ticker,))
                existing = cursor.fetchone()
                
                if existing:
                    # Rumus Akuntansi: Hitung rata-rata harga modal baru (Average Up/Down)
                    old_avg, old_qty = float(existing[0]), int(existing[1])
                    new_qty = old_qty + qty_lot
                    new_avg = ((old_avg * old_qty) + (price * qty_lot)) / new_qty
                    cursor.execute("""
                        UPDATE virtual_portfolio 
                        SET avg_buy_price = %s, current_lot_qty = %s, total_value_idr = %s, updated_at = NOW()
                        WHERE ticker = %s
                    """, (new_avg, new_qty, (new_avg * new_qty * 100), ticker))
                else:
                    cursor.execute("""
                        INSERT INTO virtual_portfolio (ticker, avg_buy_price, current_lot_qty, total_value_idr)
                        VALUES (%s, %s, %s, %s)
                    """, (ticker, price, qty_lot, gross_value))

            # -----------------------------------------------------------------
            # EKSEKUSI SIMULASI JUAL (VIRTUAL SELL)
            # -----------------------------------------------------------------
            elif side == "SELL":
                cursor.execute("SELECT current_lot_qty FROM virtual_portfolio WHERE ticker = %s", (ticker,))
                existing = cursor.fetchone()
                
                if not existing or int(existing[0]) < qty_lot:
                    return {"status": "REJECTED", "reason": "Kuantitas Saham di Portofolio Tidak Mencukupi."}
                    
                old_qty = int(existing[0])
                net_proceeds = gross_value - transaction_fee
                
                # Tambahkan Dana Hasil Jualan ke Saldo Kas Virtual dengan fallback user_id
                try:
                    cursor.execute("UPDATE virtual_account SET cash_balance_idr = cash_balance_idr + %s WHERE user_id = 1", (net_proceeds,))
                    if cursor.rowcount == 0:
                        # Fallback: update user pertama yang tersedia
                        cursor.execute("UPDATE virtual_account SET cash_balance_idr = cash_balance_idr + %s WHERE user_id = (SELECT user_id FROM virtual_account LIMIT 1)", (net_proceeds,))
                except Exception as e:
                    conn.rollback()
                    return {"status": "ERROR", "reason": f"Gagal update saldo virtual: {str(e)}"}
                
                if old_qty == qty_lot:
                    # Jika terjual semua, hapus baris emiten dari portofolio
                    cursor.execute("DELETE FROM virtual_portfolio WHERE ticker = %s", (ticker,))
                else:
                    # Jika terjual sebagian (Partial Sell)
                    new_qty = old_qty - qty_lot
                    cursor.execute("""
                        UPDATE virtual_portfolio 
                        SET current_lot_qty = %s, total_value_idr = (avg_buy_price * %s * 100), updated_at = NOW()
                        WHERE ticker = %s
                    """, (new_qty, new_qty, ticker))

            # 3. Catat riwayat audit log agar bisa divalidasi kebenarannya
            cursor.execute("""
                INSERT INTO bot_orders (ticker, side, price, quantity_lot, trigger_reason, status, broker_order_ref)
                VALUES (%s, %s, %s, %s, %s, 'FILLED', 'VIRTUAL_PAPER_ORDER')
            """, (ticker, side, price, qty_lot, f"[PAPER TRADING] {reason}"))
            
            conn.commit()
            return {"status": "SUCCESS", "side": side, "ticker": ticker, "price": price, "qty": qty_lot}
            
        except Exception as e:
            conn.rollback()
            return {"status": "ERROR", "reason": str(e)}
        finally:
            cursor.close()
            conn.close()
