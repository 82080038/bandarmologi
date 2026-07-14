# Smart Money Tracker (Bandarmologi & Order Flow Analytics)

Aplikasi pelacak pergerakan Market Maker secara real-time menggunakan analisis bandarmologi dan order flow.

## 🏗️ Arsitektur

- **Backend**: Python FastAPI dengan WebSocket untuk real-time data streaming
- **Database**: TimescaleDB (PostgreSQL extension) untuk time-series data
- **Cache**: Redis Pub/Sub untuk high-performance WebSocket data distribution
- **Frontend**: Next.js + TradingView Lightweight Charts untuk visualisasi profesional
- **Deployment**: Docker Compose untuk containerization seluruh ekosistem

## 📋 Prasyarat

### Untuk Development Manual:
- Python 3.8+
- Node.js 20+ (saat ini menggunakan Node.js 18.19.1 - ada warning kompatibilitas)
- PostgreSQL dengan TimescaleDB extension
- Redis server
- pip dan npm

### Untuk Docker Deployment:
- Docker Desktop
- Docker Compose

## 🚀 Instalasi & Setup

### 1. Setup Database TimescaleDB

```bash
# Install PostgreSQL dan TimescaleDB (Ubuntu/Debian)
sudo apt-get install postgresql timescaledb-2-postgresql-14

# Buat database
sudo -u postgres psql
CREATE DATABASE smart_money;
\c smart_money
CREATE EXTENSION timescaledb;
\q
```

Jalankan schema SQL:

```bash
cd backend
psql -U postgres -d smart_money -f schema.sql
```

### 2. Setup Backend Python

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Update database connection di main.py
# Ganti DB_PARAMS dengan koneksi database Anda:
# DB_PARAMS = "dbname=smart_money user=postgres password=YOUR_PASSWORD host=localhost"

# Jalankan server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend akan berjalan di `http://localhost:8000`

### 3. Setup Frontend Next.js

```bash
cd frontend

# Install dependencies (sudah dilakukan saat create-next-app)
npm install

# Jalankan development server
npm run dev
```

Frontend akan berjalan di `http://localhost:3000`

### 4. Docker Deployment (Production-Ready)

Untuk deployment yang lebih mudah dan konsisten, gunakan Docker Compose:

```bash
# Pastikan Docker Desktop berjalan
# Jalankan seluruh ekosistem (TimescaleDB, Redis, Backend)
docker-compose up --build -d

# Untuk melihat logs
docker-compose logs -f

# Untuk menghentikan
docker-compose down
```

Docker Compose akan otomatis:
- Menjalankan TimescaleDB untuk database time-series
- Menjalankan Redis untuk cache layer
- Menjalankan FastAPI backend dengan semua dependencies
- Mengatur networking antar container

## 🧪 Pengujian

1. Pastikan backend Python berjalan:
   ```bash
   cd backend
   uvicorn main:app --reload
   ```

2. Pastikan frontend Next.js berjalan:
   ```bash
   cd frontend
   npm run dev
   ```

3. Buka browser dan akses:
   ```
   http://localhost:3000
   ```

4. Masukkan ticker saham (contoh: BBCA, TLKM, UNVR) untuk melihat:
   - Grafik candlestick real-time
   - Volume histogram
   - Sinyal Market Maker (Accumulation/Distribution)
   - Konsentrasi Top 3 Buyer & Seller

## 📊 Fitur

### Fitur Utama
- **Real-time Chart**: Grafik candlestick dan volume yang update setiap detik
- **Market Maker Detection**: Algoritma mendeteksi akumulasi/distribusi bandar
- **Broker Concentration**: Analisis konsentrasi Top 3 broker
- **Professional UI**: Tema gelap ala TradingView untuk pengalaman trading profesional

### Fitur Tingkat Lanjut
- **AI-Powered Market Analysis**: Integrasi Google Gemini untuk opini pasar otomatis
  - Laporan PDF dengan analisis naratif cerdas dari AI LLM
  - Opini profesional berdasarkan metrik akumulasi bandar
  - Insight kontekstual untuk keputusan investasi
  - Memerlukan: `GEMINI_API_KEY` environment variable

- **Automated Trading Execution Bot**: Sistem eksekusi algoritmik otonom
  - Trading rules engine untuk keputusan beli/jual otomatis
  - Integrasi API sekuritas untuk eksekusi order real-time
  - Risk management dengan limit alokasi per trade
  - Kill switch untuk kontrol manual instan
  - Log eksekusi tercatat di database TimescaleDB
  - Memerlukan: `BROKER_API_KEY` dan `BROKER_SECRET_TOKEN` environment variables

- **Bot Controller Panel**: Dashboard kontrol eksekusi bot
  - Saklar on/off untuk aktivasi bot (Kill Switch)
  - Live order execution logs real-time
  - Status mesin dan risk limit monitoring
  - Visual feedback untuk status RUNNING/IDLE

- **Global Macro Interconnection**: Filter pasar global untuk IHSG
  - Monitoring sentimen Wall Street (S&P 500, NASDAQ) secara real-time
  - Tracking Foreign Flow (Net Buy/Sell) untuk saham IHSG
  - Lock trading otomatis saat pasar global berisiko (S&P 500 anjlok > -1.5%)
  - Bot hanya membeli jika global aman ATAU asing masuk masif (> Rp 1 Miliar)
  - Dashboard visual Global Macro Bar dengan indeks utama
  - Proteksi dari market crash global

- **Stress Testing & Crisis Simulation**: Sistem uji ketahanan algoritmik
  - Simulasi skenario krisis finansial buatan (synthetic crisis data)
  - Parameter krisis: price drop multiplier, liquidity drain, volume spike
  - Testing panel untuk trigger market crash scenario
  - Evaluasi sistem manajemen risiko sebelum deployment produksi
  - API Endpoint: `GET /api/stress-test?ticker={ticker}&scenario={scenario_name}`

- **Interest Rate Volatility Protection**: Deteksi volatilitas suku bunga
  - Average True Range (ATR) calculation untuk deteksi volatilitas abnormal
  - Lock trading 30 menit sebelum/sesudah pengumuman suku bunga (BI/Fed)
  - Threshold ATR limit (Rp 150 per menit) untuk mencegah slippage
  - Proteksi dari gejolak berita makroekonomi penting
  - Institutional-grade risk management

- **Institutional Secrets Detection**: Intelijen mikrostruktur pasar tingkat lanjut
  - **Iceberg Order Detection**: Mendeteksi order tersembunyi yang melebihi kapasitas visual 4x
  - **Dark Pool Crossing Filter**: Analisis Pasar Negosiasi untuk deteksi panic selling buatan
  - **Pre-Closing Markup Analyzer**: Deteksi kosmetik grafik pada 10 menit terakhir sesi
  - Proteksi dari manipulasi crossing saham dan mark-up penutupan
  - API Endpoint: `GET /api/institutional-secrets/{ticker}?current_price={price}`

- **Fully Autonomous Trading Robot**: Mesin keputusan berbasis logika deterministik
  - **Auto Diversification**: Batas maksimal 20% modal per saham untuk manajemen risiko
  - **Auto Buy**: Eksekusi masuk instan berdasarkan akumulasi Top 3 Broker dan kedekatan harga modal bandar
  - **Auto Cut Loss**: Proteksi statis -3% dan deteksi distribusi bandar untuk penyelamatan modal
  - **Auto Sell**: Target profit +6% dengan justifikasi logis
  - **Transparansi Penuh**: Audit trail dengan justifikasi keputusan robot
  - API Endpoint: `GET /api/bot-audit-logs`

- **Daily Performance Notifications**: Sistem notifikasi otomatis berlatensi rendah
  - **Email Export**: Laporan harian otomatis ke email dengan format HTML profesional
  - **SSE Streaming**: Server-Sent Events untuk notifikasi real-time tanpa refresh
  - **In-App Toast**: Pop-up notifikasi modern di dashboard dengan unread counter
  - **Cron Trigger**: Otomatis dipicu setelah penutupan bursa (16.15 WIB)
  - **Riwayat Notifikasi**: Database log untuk audit trail lengkap
  - API Endpoints: `POST /api/trigger-daily-report`, `GET /api/notifications/stream`

- **Paper Trading (Virtual Account)**: Simulasi trading dengan risiko 0%
  - **Virtual Account**: Saldo tunai virtual Rp 100 Juta untuk testing algoritma
  - **Virtual Portfolio**: Tracking kepemilikan saham virtual dengan akuntansi rata-rata
  - **Brokerage Fee Simulation**: Biaya transaksi realistis (0.15% beli, 0.25% jual)
  - **Real-time Testing**: Uji performa algoritma dengan data pasar riil tanpa risiko finansial
  - **Sandbox Mode**: Lingkungan aman untuk eksperimen strategi trading
  - **Dynamic Capital Reset**: Ubah modal awal secara dinamis (Rp 500 Juta, Rp 1 Miliar, dll)
  - **Auto Diversification Adaptation**: Robot beradaptasi secara matematis dengan perubahan modal
  - API Endpoints: `GET /api/virtual-account-status`, `POST /api/virtual-account/reset`

- **Market Calendar Module**: Kesadaran waktu presisi sesuai regulasi BEI
  - **Trading Session Rules**: Sesi 1 (09:00-12:00), Sesi 2 (13:30-16:15), Pre-Closing (15:50-16:15)
  - **Weekend Detection**: Otomatis non-aktif pada Sabtu & Minggu
  - **Holiday Calendar**: Database hari libur nasional (Tahun Baru, Nyepi, Natal, dll)
  - **Break Time Handling**: Mode hemat daya saat jam istirahat siang (12:00-13:30)
  - **Server Efficiency**: Menghemat CPU dengan sleep mode saat bursa tutup
  - **Error Prevention**: Mencegah crash akibat data kosong saat pasar tutup
  - **Daemon Integration**: Loop bot dengan pengecekan waktu otomatis

- **Automation Cron-Daemon**: Penjadwalan robot otomatis berbasis waktu BEI
  - **Morning Readiness Email**: Notifikasi kesiapan sistem pukul 08.45 WIB
  - **Session Automation**: On/off otomatis sesuai jadwal Sesi 1 dan Sesi 2
  - **Background Scheduler**: APScheduler untuk cron jobs presisi
  - **Timezone WIB**: Zona waktu Asia/Jakarta untuk akurasi jadwal
  - **Holiday Awareness**: Skip jadwal saat hari libur nasional
  - **Status Monitoring**: Widget indikator status operasional real-time
  - **Efficiency**: Hemat CPU dengan sleep mode saat bursa tutup
  - API Endpoint: `GET /api/bot-status`

- **Portfolio Risk Management**: Manajemen risiko portofolio tingkat institusi
  - **Dynamic Position Sizing**: Ukuran posisi berbasis volatilitas (ATR)
  - **ATR-Based Sizing**: Rumus VaR untuk toleransi risiko per transaksi
  - **Risk per Trade**: Maksimal 0.5% modal per transaksi
  - **Diversification Limit**: Maksimal 20% modal per saham
  - **Prudence Principle**: Ambil nilai lot terkecil untuk kehati-hatian
  - **Circuit Breaker**: Rem darurat saat kerugian harian -2%
  - **Daily Drawdown Protection**: Kunci bot saat batas kerugian terlampaui
  - **Equity Curve Analytics**: Tracking performa jangka panjang
  - **Win Rate & Profit Factor**: Metrik statistik performa robot
  - API Endpoint: `GET /api/equity-analytics`

- **Redis Pub/Sub WebSocket**: High-performance real-time data streaming
  - Sub-milisecond latency untuk data feed
  - Mengurangi beban database dengan cache layer
  - Scalable untuk ratusan concurrent users

- **Multi-Ticker Matrix View**: Dasbor multipantau sektoral untuk analisis komparatif
  - Memantau banyak saham sekaligus dalam satu layar matriks
  - Mendeteksi rotasi sektoral (sectoral rotation) secara real-time
  - Klik baris saham untuk langsung melihat grafik detail tanpa reload halaman
  - Update otomatis setiap 3 detik
  - API Endpoint: `GET /api/matrix?tickers=BBCA,BBRI,BMRI,BBNI`

- **PDF Report Export**: Generate laporan riset pasar otomatis dengan AI
  - Ekspor analisis institusional ke format PDF profesional
  - Termasuk ringkasan eksekutif dan tabel data transaksi
  - Insight AI LLM untuk interpretasi pasar yang mendalam
  - Desain dokumen kelas institusi dengan ReportLab
  - API Endpoint: `GET /api/report/pdf/{ticker}`

- **Spoofing Detector**: Mendeteksi manipulasi antrean palsu (fake order walls) dalam hitungan detik
  - Mendeteksi pembatalan antrean volume besar secara mendadak
  - Validasi silang dengan data transaksi untuk membedakan spoofing dari matched orders
  - API Endpoint: `GET /api/spoof-detector/{ticker}`
  
- **Market Maker Average Price**: Menghitung harga modal rata-rata (VWAP) penggerak pasar
  - Mengidentifikasi Top 3 broker akumulator dalam periode tertentu (default: 20 hari)
  - Menghitung Volume Weighted Average Price (VWAP) masing-masing bandar
  - Menampilkan garis horizontal "MODAL BANDAR" pada chart sebagai area pertahanan psikologis
  - API Endpoint: `GET /api/market-maker-avg/{ticker}?days=20`

## 🔌 API Endpoints

### Analytics
- `GET /api/analytics/{ticker}` - Analisis market maker status dan konsentrasi broker
- `GET /api/spoof-detector/{ticker}` - Deteksi manipulasi antrean (spoofing)
- `GET /api/market-maker-avg/{ticker}?days=20` - Harga rata-rata modal bandar
- `GET /api/matrix?tickers=BBCA,BBRI,BMRI,BBNI` - Multi-ticker matrix view untuk analisis sektoral
- `GET /api/report/pdf/{ticker}` - Generate laporan PDF analisis institusional

### WebSocket
- `WS /ws/trades/{ticker}` - Real-time data streaming untuk chart

## 🔧 Konfigurasi

### Backend Configuration

Edit `backend/main.py` untuk mengubah:
- Database connection string
- WebSocket interval
- Mock data vs real data feed

### Environment Variables

Untuk fitur AI dan Automated Trading Bot, set environment variables berikut:

```bash
# Untuk AI LLM (Google Gemini)
export GEMINI_API_KEY="your_gemini_api_key_here"

# Untuk Trading Bot (API Sekuritas)
export BROKER_API_KEY="your_broker_api_key_here"
export BROKER_SECRET_TOKEN="your_broker_secret_token_here"
```

### Frontend Configuration

Edit `frontend/src/app/page.tsx` untuk mengubah:
- Polling interval analytics (default: 5000ms)
- Default ticker (default: BBCA)

## 📝 Catatan Penting

- Saat ini menggunakan **mock data** untuk simulasi. Untuk produksi, hubungkan dengan API broker/bursa asli.
- Node.js version warning: Aplikasi menggunakan Node.js 18.19.1, disarankan upgrade ke Node.js 20+ untuk kompatibilitas penuh dengan Next.js terbaru.
- Database connection perlu dikonfigurasi sesuai environment lokal Anda.

## 🛠️ Troubleshooting

### Backend tidak connect ke database
- Pastikan PostgreSQL berjalan
- Cek kredensial di `DB_PARAMS`
- Pastikan database `smart_money` sudah dibuat

### Frontend tidak connect ke backend
- Pastikan backend berjalan di port 8000
- Cek CORS configuration di `main.py`
- Cek browser console untuk error WebSocket

### Chart tidak muncul
- Pastikan `lightweight-charts` sudah terinstall
- Cek browser console untuk error JavaScript
- Pastikan WebSocket connection berhasil

## 📄 Lisensi

Proyek ini dibuat untuk tujuan edukasi dan analisis pasar modal.
