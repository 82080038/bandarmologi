"use client";

import { useEffect, useState } from "react";

interface Notification {
  title: string;
  message: string;
  type: string;
}

export default function NotificationToast() {
  const [activeNotif, setActiveNotif] = useState<Notification | null>(null);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    // Membuka jalur pipa data SSE ke Backend FastAPI
    const eventSource = new EventSource("http://localhost:8000/api/notifications/stream");

    eventSource.onmessage = (event) => {
      const newNotif = JSON.parse(event.data);
      setActiveNotif(newNotif);
      setUnreadCount(prev => prev + 1);

      // Hilangkan pop-up toast otomatis setelah 7 detik
      setTimeout(() => {
        setActiveNotif(null);
      }, 7000);
    };

    return () => {
      eventSource.close();
    };
  }, []);

  return (
    <div className="relative font-sans">
      {/* Tombol Lonceng Indikator di Header */}
      <button className="relative p-2 bg-[#1e222d] border border-gray-800 rounded hover:border-emerald-400 transition-colors">
        🔔
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 bg-emerald-500 text-white font-mono text-[9px] font-bold px-1.5 py-0.5 rounded-full animate-bounce">
            {unreadCount}
          </span>
        )}
      </button>

      {/* POP-UP TOAST NOTIFIKASI REAL-TIME */}
      {activeNotif && (
        <div className="fixed bottom-6 right-6 z-50 max-w-sm w-96 bg-[#131722] border-l-4 border-emerald-500 text-white p-4 rounded shadow-[0_10px_30px_rgba(0,0,0,0.5)] border border-gray-800 animate-slide-in">
          <div className="flex justify-between items-start mb-1">
            <h4 className="text-xs font-black tracking-wider text-emerald-400 uppercase">
              🚀 {activeNotif.title}
            </h4>
            <button onClick={() => setActiveNotif(null)} className="text-gray-500 hover:text-white text-xs">✕</button>
          </div>
          <p className="text-xs text-gray-300 leading-relaxed font-mono">
            {activeNotif.message}
          </p>
        </div>
      )}
    </div>
  );
}
