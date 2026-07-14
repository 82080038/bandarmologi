from datetime import datetime, time
import psycopg2

DB_PARAMS = "dbname=smart_money user=postgres password=secret host=timescaledb port=5432"

def is_market_open() -> tuple[bool, str]:
    """
    Memeriksa apakah waktu saat ini berada di dalam jam kerja aktif 
    Bursa Efek Indonesia (IHSG) untuk menghemat efisiensi server.
    """
    now = datetime.now()
    current_time = now.time()
    current_day = now.weekday() # 0 = Senin, 5 = Sabtu, 6 = Minggu

    # 1. VALIDASI HARI LIBUR AKHIR PEKAN (SABTU & MINGGU)
    if current_day >= 5:
        return False, "MARKET_CLOSED_WEEKEND"

    # 2. VALIDASI HARI LIBUR NASIONAL / KALENDER BEI
    # (Mengecek ke tabel database lokal yang berisi daftar tanggal libur resmi bursa)
    current_date_str = now.strftime("%Y-%m-%d")
    conn = psycopg2.connect(DB_PARAMS)
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM idx_holidays WHERE holiday_date = %s", (current_date_str,))
    is_holiday = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if is_holiday:
        return False, "MARKET_CLOSED_HOLIDAY"

    # 3. VALIDASI JAM OPERASIONAL & JAM ISTIRAHAT (WIB)
    # Sesi 1
    session_1_start = time(9, 0, 0)
    session_1_end = time(12, 0, 0)
    
    # Sesi 2 s.d. Pasca Penutupan
    session_2_start = time(13, 30, 0)
    market_end = time(16, 15, 0)

    # Memeriksa apakah berada di dalam jendela waktu Sesi 1 atau Sesi 2
    if session_1_start <= current_time <= session_1_end:
        return True, "SESSION_1_ACTIVE"
    elif session_2_start <= current_time <= market_end:
        return True, "SESSION_2_ACTIVE"
    elif time(12, 0, 1) <= current_time < time(13, 30, 0):
        return False, "MARKET_BREAK_TIME" # Jam Istirahat Siang
    else:
        return False, "MARKET_CLOSED_NIGHT" # Malam Hari / Bursa Tutup
