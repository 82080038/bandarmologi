"use client";

import { useEffect, useState } from "react";

export default function BotTimeStatusWidget() {
  const [isBotActive, setIsBotActive] = useState(false);

  useEffect(() => {
    async function fetchBotStatus() {
      try {
        const res = await fetch("http://localhost:8000/api/bot-status");
        const data = await res.json();
        setIsBotActive(data.is_running);
      } catch (err) {
        console.error("Gagal mengambil status bot", err);
      }
    }
    fetchBotStatus();
    const interval = setInterval(fetchBotStatus, 5000); // Update setiap 5 detik
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex items-center gap-2 bg-[#1c2030] border border-gray-800 px-3 py-1.5 rounded font-mono text-xs">
      <span className="text-gray-500">KORELASI WAKTU BURSA:</span>
      <div className="flex items-center gap-1.5">
        {isBotActive ? (
          <>
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping" />
            <span className="text-emerald-400 font-bold">ROBOT BEROPERASI (SESI AKTIF)</span>
          </>
        ) : (
          <>
            <span className="w-2 h-2 rounded-full bg-gray-600" />
            <span className="text-gray-400">ROBOT STANDBY (BURSA TUTUP / ISTIRAHAT)</span>
          </>
        )}
      </div>
    </div>
  );
}
