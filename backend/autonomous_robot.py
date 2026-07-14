import psycopg2
import pandas as pd
from bot_engine import send_order_to_broker

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

class AutonomousTradingRobot:
    def __init__(self, total_equity_idr: float):
        self.total_equity = total_equity_idr
        # AUTO DIVERSIFIKASI: Maksimal 20% modal per saham, maksimal memegang 5 saham berbeda
        self.max_allocation_per_ticker = total_equity_idr * 0.20 
        
    def get_portfolio_status(self, ticker: str):
        """Membaca posisi portofolio riil saat ini dari database."""
        conn = psycopg2.connect(DB_PARAMS)
        query = "SELECT avg_buy_price, current_lot_qty FROM user_portfolio WHERE ticker = %s"
        df = pd.read_sql_query(query, conn, params=(ticker.upper(),))
        conn.close()
        
        if df.empty or df['current_lot_qty'].iloc[0] == 0:
            return None
        return {"avg_price": float(df['avg_buy_price'].iloc[0]), "qty": int(df['current_lot_qty'].iloc[0])}

    def execute_autonomous_cycle(self, ticker: str, current_price: int, mm_metrics: dict):
        """
        Sirkuit Otomatisasi Total: Berjalan setiap 1 detik per saham untuk 
        mengambil keputusan logis tanpa intervensi manusia.
        """
        ticker = ticker.upper()
        position = self.get_portfolio_status(ticker)
        
        # -----------------------------------------------------------------
        # KONDISI A: KITA SUDAH PUNYA BARANG (AUTO SELL / AUTO CUT / AUTO RISK)
        # -----------------------------------------------------------------
        if position:
            avg_buy_price = position["avg_price"]
            current_return_pct = ((current_price - avg_buy_price) / avg_buy_price) * 100
            
            # 1. AUTO CUT (Batas Rugi Statis)
            if current_return_pct <= -3.0:
                reason = f"AUTO_CUT: Harga turun {round(current_return_pct, 2)}% menyentuh batas proteksi modal -3%."
                send_order_to_broker(ticker, "SELL", current_price, position["qty"])
                self.log_robot_action(ticker, "SELL", current_price, position["qty"], reason)
                return

            # 2. AUTO CUT BANDARMOLOGI (Deteksi Bandar Kabur)
            if mm_metrics.get('status') == "BIG DISTRIBUTION":
                reason = "AUTO_CUT_BANDARMOLOGI: Terdeteksi distribusi raksasa dari Top 3 Broker. Amankan modal segera."
                send_order_to_broker(ticker, "SELL", current_price, position["qty"])
                self.log_robot_action(ticker, "SELL", current_price, position["qty"], reason)
                return

            # 3. AUTO SELL (Target Profit Logis)
            if current_return_pct >= 6.0:
                reason = f"AUTO_SELL: Target profit +6% tercapai (Return saat ini: {round(current_return_pct, 2)}%)."
                send_order_to_broker(ticker, "SELL", current_price, position["qty"])
                self.log_robot_action(ticker, "SELL", current_price, position["qty"], reason)
                return
                
        # -----------------------------------------------------------------
        # KONDISI B: KITA BELUM PUNYA BARANG (AUTO MODAL & AUTO BUY)
        # -----------------------------------------------------------------
        else:
            # 1. AUTO BUY CHECK: Validasi Sinyal Akumulasi & Kedekatan Harga Modal Bandar
            if mm_metrics.get('status') == "BIG ACCUMULATION" and current_price <= (mm_metrics.get('bandar_avg_cost', current_price) * 1.01):
                
                # 2. AUTO MODAL: Hitung berapa lot yang boleh dibeli berdasarkan batas diversifikasi 20%
                # Rumus: (Maksimal Alokasi Rp) / (Harga Saham Per Lembar * 100 Lembar per Lot)
                allowed_qty_lot = int(self.max_allocation_per_ticker / (current_price * 100))
                
                if allowed_qty_lot > 0:
                    reason = f"AUTO_BUY: Terdeteksi akumulasi besar institusi dekat harga modal mereka (Rp {mm_metrics.get('bandar_avg_cost')})."
                    
                    # Kirim order beli otomatis ke bursa via API
                    send_order_to_broker(ticker, "BUY", current_price, allowed_qty_lot)
                    
                    # Catat justifikasi keputusan ke database log
                    self.log_robot_action(ticker, "BUY", current_price, allowed_qty_lot, reason)
                else:
                    print(f"[BOT LOG] Modal tidak mencukupi untuk alokasi diversifikasi pada saham {ticker}")

    def log_robot_action(self, ticker: str, side: str, price: int, qty: int, reason: str):
        """Mencatat JUSTIFIKASI LOGIS robot ke dalam database agar transparan."""
        conn = psycopg2.connect(DB_PARAMS)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO bot_orders (ticker, side, price, quantity_lot, trigger_reason, status)
            VALUES (%s, %s, %s, %s, %s, 'EXECUTED')
        """, (ticker, side, price, qty, reason))
        conn.commit()
        cursor.close()
        conn.close()
        print(f"🤖 [ROBOT OTONOM] Eksekusi {side} {ticker} | Alasan: {reason}")
