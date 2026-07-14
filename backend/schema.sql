-- Membuat tabel dasar data transaksi tick-by-tick
CREATE TABLE IF NOT EXISTS market_trades (
    time TIMESTAMPTZ NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    price NUMERIC NOT NULL,
    volume INT NOT NULL,
    buyer_broker VARCHAR(5),
    seller_broker VARCHAR(5),
    trade_type VARCHAR(10) -- 'HAKA' (Beli di Offer) atau 'HAKI' (Jual di Bid)
);

-- Mengubah tabel menjadi Hypertable (Fitur Utama TimescaleDB)
-- Pastikan TimescaleDB sudah terinstall sebelum menjalankan ini
SELECT create_hypertable('market_trades', 'time', if_not_exists => TRUE);

-- Indeks untuk mempercepat pencarian per saham
CREATE INDEX IF NOT EXISTS idx_ticker_time ON market_trades (ticker, time DESC);

-- Tabel untuk mencatat perubahan antrean Bid dan Ask (Market Depth)
CREATE TABLE IF NOT EXISTS order_book_snapshots (
    time TIMESTAMPTZ NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    price NUMERIC NOT NULL,
    type VARCHAR(4) NOT NULL,       -- 'BID' atau 'ASK'
    total_volume_lot INT NOT NULL,  -- Volume total di harga tersebut
    queue_count INT NOT NULL        -- Jumlah antrean order (jika disuplai oleh bursa)
);

-- Ubah menjadi hypertable berbasis waktu
SELECT create_hypertable('order_book_snapshots', 'time', if_not_exists => TRUE);

-- Buat indeks komposit untuk optimasi kueri pendeteksi spoofing
CREATE INDEX IF NOT EXISTS idx_ob_spoof ON order_book_snapshots (ticker, price, time DESC);

-- Tabel untuk mencatat log instruksi, status eksekusi, dan pelacakan portofolio otonom
CREATE TABLE IF NOT EXISTS bot_orders (
    order_id SERIAL PRIMARY KEY,
    time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ticker VARCHAR(10) NOT NULL,
    side VARCHAR(4) NOT NULL,          -- 'BUY' atau 'SELL'
    price NUMERIC NOT NULL,
    quantity_lot INT NOT NULL,
    trigger_reason TEXT,               -- Alasan keputusan (misal: 'Big Acc + Modal Bandar')
    status VARCHAR(15) NOT NULL,       -- 'PENDING', 'FILLED', 'REJECTED'
    broker_order_ref VARCHAR(50)       -- ID Referensi unik dari API Sekuritas
);

-- Indeks untuk optimasi pencarian riwayat order bot
CREATE INDEX IF NOT EXISTS idx_bot_ticker_time ON bot_orders (ticker, time DESC);

-- Tabel untuk memantau sentimen pasar global secara real-time
CREATE TABLE IF NOT EXISTS global_sentiment (
    time TIMESTAMPTZ NOT NULL,
    index_name VARCHAR(20) NOT NULL, -- 'SP500', 'NASDAQ', 'DXY' (Dolar Index), 'COMPOSITE' (IHSG)
    last_price NUMERIC NOT NULL,
    daily_change_percent NUMERIC NOT NULL
);

SELECT create_hypertable('global_sentiment', 'time', if_not_exists => TRUE);

-- Indeks untuk optimasi pencarian sentimen global
CREATE INDEX IF NOT EXISTS idx_global_name_time ON global_sentiment (index_name, time DESC);

-- Tabel untuk melacak pergerakan dana asing (Foreign Flow) khusus di IHSG
CREATE TABLE IF NOT EXISTS foreign_flow_ihsg (
    time TIMESTAMPTZ NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    foreign_buy_volume INT NOT NULL,
    foreign_sell_volume INT NOT NULL,
    net_foreign_val_idr BIGINT NOT NULL -- Nilai bersih rupiah (Beli - Jual)
);

SELECT create_hypertable('foreign_flow_ihsg', 'time', if_not_exists => TRUE);

-- Indeks untuk optimasi pencarian foreign flow per ticker
CREATE INDEX IF NOT EXISTS idx_foreign_ticker_time ON foreign_flow_ihsg (ticker, time DESC);

-- Tabel untuk menyimpan parameter riwayat krisis untuk stress testing
CREATE TABLE IF NOT EXISTS stress_test_scenarios (
    scenario_id SERIAL PRIMARY KEY,
    scenario_name VARCHAR(50) NOT NULL,    -- Contoh: 'GLOBAL_CRASH_2020', 'TECH_BUBBLE'
    price_drop_multiplier NUMERIC NOT NULL, -- Contoh: 0.90 (Turun 10% per menit)
    liquidity_drain_ratio NUMERIC NOT NULL, -- Contoh: 0.80 (80% antrean Bid menghilang)
    volume_spike_multiplier INT NOT NULL   -- Contoh: 5 (Volume jual melonjak 5x lipat)
);

-- Masukkan data parameter dasar krisis finansial global ke database
INSERT INTO stress_test_scenarios (scenario_name, price_drop_multiplier, liquidity_drain_ratio, volume_spike_multiplier)
VALUES ('SYSTEMIC_GLOBAL_PANIC', 0.85, 0.75, 6)
ON CONFLICT DO NOTHING;

-- Tabel khusus untuk memantau Pasar Negosiasi (Membongkar Rahasia Crossing Saham)
CREATE TABLE IF NOT EXISTS negotiated_market_trades (
    time TIMESTAMPTZ NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    price NUMERIC NOT NULL,
    volume INT NOT NULL,
    buyer_broker VARCHAR(5),
    seller_broker VARCHAR(5),
    total_value_idr BIGINT NOT NULL
);

SELECT create_hypertable('negotiated_market_trades', 'time', if_not_exists => TRUE);

-- Tambahkan indeks pencarian cepat untuk membandingkan Pasar Reguler vs Negosiasi
CREATE INDEX IF NOT EXISTS idx_neg_market ON negotiated_market_trades (ticker, time DESC);

-- Tabel untuk tracking posisi portofolio robot otonom
CREATE TABLE IF NOT EXISTS user_portfolio (
    ticker VARCHAR(10) PRIMARY KEY,
    avg_buy_price NUMERIC NOT NULL,
    current_lot_qty INT NOT NULL DEFAULT 0,
    total_invested_idr BIGINT NOT NULL DEFAULT 0,
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indeks untuk optimasi pencarian portofolio
CREATE INDEX IF NOT EXISTS idx_portfolio_ticker ON user_portfolio (ticker);

-- Tabel untuk menyimpan riwayat notifikasi aplikasi
CREATE TABLE IF NOT EXISTS app_notifications (
    id SERIAL PRIMARY KEY,
    time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'INFO', 'SUCCESS', 'CRITICAL_RISK'
    is_read BOOLEAN DEFAULT FALSE
);

-- Indeks untuk optimasi pencarian notifikasi
CREATE INDEX IF NOT EXISTS idx_notifications_time ON app_notifications (time DESC);

-- Tabel untuk menyimpan Saldo Tunai Virtual User (Paper Trading)
CREATE TABLE IF NOT EXISTS virtual_account (
    user_id SERIAL PRIMARY KEY,
    cash_balance_idr NUMERIC NOT NULL DEFAULT 100000000.00, -- Default modal Rp 100 Juta
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Masukkan saldo awal untuk akun simulasi Anda
INSERT INTO virtual_account (cash_balance_idr) VALUES (100000000.00)
ON CONFLICT DO NOTHING;

-- Tabel untuk mencatat kepemilikan saham virtual saat ini
CREATE TABLE IF NOT EXISTS virtual_portfolio (
    ticker VARCHAR(10) PRIMARY KEY,
    avg_buy_price NUMERIC NOT NULL,
    current_lot_qty INT NOT NULL,
    total_value_idr NUMERIC NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indeks untuk optimasi pencarian portofolio virtual
CREATE INDEX IF NOT EXISTS idx_virtual_portfolio_ticker ON virtual_portfolio (ticker);

-- Membuat prosedur fungsi untuk reset akun simulasi secara instan
CREATE OR REPLACE PROCEDURE reset_paper_trading_account(new_balance NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Kembalikan kas ke nominal parameter baru pada user_id = 1
    UPDATE virtual_account 
    SET cash_balance_idr = new_balance, updated_at = NOW()
    WHERE user_id = 1;
    
    -- Jika user belum ada (inisialisasi awal), buat baris baru
    IF NOT FOUND THEN
        INSERT INTO virtual_account (user_id, cash_balance_idr) VALUES (1, new_balance);
    END IF;

    -- 2. Bersihkan seluruh kepemilikan saham dari simulasi sebelumnya
    DELETE FROM virtual_portfolio;
    
    -- 3. Catat aksi pembersihan sistem ke log audit bursa
    INSERT INTO bot_orders (ticker, side, price, quantity_lot, trigger_reason, status, broker_order_ref)
    VALUES ('SYSTEM', 'NONE', 0, 0, CONCAT('[RESET] Akun simulasi disetel ulang dengan modal awal baru: Rp ', new_balance), 'SUCCESS', 'SYSTEM_RESET');
END;
$$;

-- Tabel untuk menyimpan daftar hari libur Bursa Efek Indonesia (BEI)
CREATE TABLE IF NOT EXISTS idx_holidays (
    holiday_date DATE PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);

-- Contoh memasukkan data libur bursa
INSERT INTO idx_holidays (holiday_date, description) VALUES 
('2026-01-01', 'Tahun Baru Masehi'),
('2026-03-19', 'Hari Raya Nyepi'),
('2026-12-25', 'Hari Raya Natal')
ON CONFLICT DO NOTHING;

-- Tabel untuk menyimpan performa portofolio harian (Equity Curve Analytics)
CREATE TABLE IF NOT EXISTS equity_performance (
    date DATE PRIMARY KEY,
    total_equity NUMERIC NOT NULL,
    daily_pnl NUMERIC NOT NULL,
    daily_pnl_percent NUMERIC NOT NULL,
    total_trades INT NOT NULL,
    winning_trades INT NOT NULL,
    losing_trades INT NOT NULL,
    win_rate NUMERIC NOT NULL,
    profit_factor NUMERIC NOT NULL,
    max_drawdown NUMERIC NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indeks untuk optimasi pencarian performa
CREATE INDEX IF NOT EXISTS idx_equity_date ON equity_performance (date DESC);
