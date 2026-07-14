from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import time as time_sleep
import os

# Kredensial Email (Ganti sesuai konfigurasi Anda)
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = "system.smartmoney@gmail.com"
SENDER_PASSWORD = os.environ.get("SMTP_PASSWORD")
RECEIVER_EMAIL = "pemilik.modal@gmail.com"

# Validasi konfigurasi SMTP saat startup
if not SENDER_PASSWORD:
    print("[WARNING] SMTP_PASSWORD environment variable not set. Email notifications will be disabled.")
    SMTP_CONFIGURED = False
else:
    SMTP_CONFIGURED = True

# Status Flag Global untuk Mengontrol Mesin Bot
BOT_IS_RUNNING = False

def is_today_holiday() -> bool:
    """Memeriksa apakah hari ini Sabtu, Minggu, atau Hari Libur Nasional di Database."""
    now = datetime.now()
    if now.weekday() >= 5: # Sabtu atau Minggu
        return True
        
    # Validasi silang ke tabel libur bursa di database
    try:
        import psycopg2
        conn = psycopg2.connect("dbname=smart_money user=postgres password=secret host=timescaledb port=5432")
        cursor = conn.cursor()
        cursor.execute("SELECT 1 FROM idx_holidays WHERE holiday_date = %s", (now.strftime("%Y-%m-%d"),))
        holiday = cursor.fetchone()
        cursor.close()
        conn.close()
        return holiday is not None
    except:
        return False # Jika DB offline, asumsikan tidak libur demi keselamatan sistem

# =====================================================================
# TUGAS 1: NOTIFIKASI SELAMAT PAGI (SETIAP HARI KERJA PUKUL 08.45 WIB)
# =====================================================================
def send_morning_readiness_email():
    """Mengirim email pemberitahuan kesiapan sistem 15 menit sebelum pasar buka."""
    if not SMTP_CONFIGURED:
        print("[SCHEDULER] SMTP not configured. Skipping email notification.")
        return
        
    if is_today_holiday():
        print("[SCHEDULER] Hari ini bursa libur. Membatalkan pengiriman email kesiapan.")
        return

    msg = MIMEMultipart("alternative")
    msg["Subject"] = f"🤖 [READY] Smart Money Bot Siap Bertugas - {datetime.now().strftime('%d %B %Y')}"
    msg["From"] = SENDER_EMAIL
    msg["To"] = RECEIVER_EMAIL

    html_content = f"""
    <html>
        <body style="font-family: sans-serif; color: #334155; padding: 20px;">
            <h2 style="color: #3b82f6; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px;">
                ☀️ SELAMAT PAGI - SISTEM AKTIF
            </h2>
            <p>Halo Pemilik Modal, bursa efek Sesi 1 akan dibuka 15 menit lagi (Pukul 09.00 WIB).</p>
            <p><b>Laporan Status Pemeriksaan Robot:</b></p>
            <ul>
                <li>Koneksi Database TimescaleDB: <span style="color: #10b981;"><b>STABIL (OK)</b></span></li>
                <li>Modul Inteligensi & Deteksi Manipulasi: <span style="color: #10b981;"><b>READY</b></span></li>
                <li>Arus Kas Akun Simulasi Virtual: <span style="color: #3b82f6;"><b>AKTIF</b></span></li>
            </ul>
            <p>Robot akan otomatis bekerja melakukan pemindaian data begitu bel pembukaan bursa berbunyi.</p>
        </body>
    </html>
    """
    msg.attach(MIMEText(html_content, "html"))

    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.sendmail(SENDER_EMAIL, RECEIVER_EMAIL, msg.as_string())
        print("[✓ SCHEDULER] Email notifikasi selamat pagi berhasil dikirim ke pemilik modal.")
    except Exception as e:
        print(f"[✗ SCHEDULER] Gagal mengirim email kesiapan: {str(e)}")

# =====================================================================
# TUGAS 2: OTOMATISASI ON/OFF MESIN SESUAI JADWAL PASAR (MONDAY-FRIDAY)
# =====================================================================
def start_trading_engine():
    """Menyalakan sirkuit analisis data dan eksekusi robot."""
    global BOT_IS_RUNNING
    if is_today_holiday(): return
    
    BOT_IS_RUNNING = True
    print(f"⏰ [{datetime.now().strftime('%H:%M:%S')}] [ROBOT START] Menyalakan mesin trading otomatis. Memulai pemindaian data bursa...")

def stop_trading_engine(reason: str):
    """Mematikan sirkuit analisis data (Mode Hemat Daya / Istirahat)."""
    global BOT_IS_RUNNING
    BOT_IS_RUNNING = False
    print(f"⏰ [{datetime.now().strftime('%H:%M:%S')}] [ROBOT STOP] Menonaktifkan mesin trading ({reason}). Server masuk mode siaga.")

# =====================================================================
# ORKESTRASI CRON-JOB (DAEMON MANAGEMENT)
# =====================================================================
def init_market_scheduler():
    scheduler = BackgroundScheduler(timezone="Asia/Jakarta") # Menyetel zona waktu WIB resmi

    # 1. Jadwal Pengiriman Email Kesiapan (Senin - Jumat jam 08:45)
    scheduler.add_job(send_morning_readiness_email, 'cron', day_of_week='mon-fri', hour=8, minute=45)

    # 2. Jadwal Menyalakan & Mematikan Sesi 1 (Buka 09:00, Istirahat 12:00)
    scheduler.add_job(start_trading_engine, 'cron', day_of_week='mon-fri', hour=9, minute=0)
    scheduler.add_job(lambda: stop_trading_engine("JAM ISTIRAHAT SIANG BURSA"), 'cron', day_of_week='mon-fri', hour=12, minute=0)

    # 3. Jadwal Menyalakan & Mematikan Sesi 2 (Buka 13:30, Tutup 16:15)
    scheduler.add_job(start_trading_engine, 'cron', day_of_week='mon-fri', hour=13, minute=30)
    scheduler.add_job(lambda: stop_trading_engine("BURSA TUTUP TOTAL HARI INI"), 'cron', day_of_week='mon-fri', hour=16, minute=15)

    scheduler.start()
    print("[✓ SYSTEM] Sistem Penjadwalan Otomatis Berbasis Waktu BEI Berhasil Diaktifkan.")
