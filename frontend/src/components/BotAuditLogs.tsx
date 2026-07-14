"use client";

import { useEffect, useState } from "react";

interface BotLog {
  id: number;
  time: string;
  ticker: string;
  side: string;
  price: number;
  qty: number;
  trigger_reason: string;
  status: string;
}

export default function BotAuditLogs() {
  const [logs, setLogs] = useState<BotLog[]>([]);

  useEffect(() => {
    async function fetchLogs() {
      // Menarik data log transaksi terbaru beserta kolom 'trigger_reason' dari backend
      const res = await fetch("http://localhost:8000/api/bot-audit-logs");
      const data = await res.json();
      setLogs(data);
    }
    fetchLogs();
    const interval = setInterval(fetchLogs, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-gray-800">
      <h3 className="text-xs font-bold text-emerald-400 uppercase tracking-wider mb-3">
        📋 ROBOT RESPONSIBILITY AUDIT LOG (TRANSPARANSI KEPUTUSAN)
      </h3>
      <div className="overflow-y-auto max-h-48 space-y-2 pr-1 font-mono text-[11px]">
        {logs.map((log) => (
          <div key={log.id} className="p-2.5 rounded bg-[#0c0d14] border border-gray-900 flex flex-col md:flex-row md:justify-between gap-1">
            <div className="flex items-center gap-2">
              <span className="text-gray-600">[{log.time}]</span>
              <span className={`font-bold px-1.5 py-0.5 rounded text-[10px] ${log.side === "BUY" ? "bg-emerald-500/10 text-emerald-400" : "bg-red-500/10 text-red-400"}`}>
                {log.side}
              </span>
              <span className="text-white font-bold text-xs">{log.ticker}</span>
              <span className="text-gray-400">@{log.price} ({log.qty} Lot)</span>
            </div>
            {/* INILAH ALASAN LOGIS YANG DIKELUARKAN ROBOT */}
            <div className="text-gray-400 italic md:text-right border-t md:border-t-0 border-gray-900 pt-1 md:pt-0">
              💬 <span className="text-emerald-500/90 font-sans">Justifikasi:</span> {log.trigger_reason}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
