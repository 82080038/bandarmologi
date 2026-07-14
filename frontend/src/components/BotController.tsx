"use client";

import { useState, useEffect } from "react";

interface BotControllerProps {
  ticker: string;
}

export default function BotController({ ticker }: BotControllerProps) {
  const [isBotActive, setIsBotActive] = useState(false);
  const [orderLogs, setOrderLogs] = useState<any[]>([]);

  // Simulasi penarikan riwayat transaksi bot dari API
  useEffect(() => {
    if (isBotActive) {
      const mockLog = {
        id: Math.random(),
        time: new Date().toLocaleTimeString(),
        ticker: ticker,
        side: "BUY",
        price: "Rp 5.025",
        status: "FILLED"
      };
      setOrderLogs(prev => [mockLog, ...prev]);
    }
  }, [isBotActive, ticker]);

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-gray-800">
      <div className="flex justify-between items-center border-b border-gray-800 pb-3 mb-4">
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider">Algorithmic Execution Bot</h3>
        
        {/* SAKLAR UTAMA BOT (KILL SWITCH) */}
        <button
          onClick={() => setIsBotActive(!isBotActive)}
          className={`px-4 py-1.5 rounded text-xs font-black transition-all ${
            isBotActive 
              ? "bg-red-500 hover:bg-red-600 text-white shadow-[0_0_10px_rgba(239,68,68,0.4)]" 
              : "bg-emerald-500 hover:bg-emerald-600 text-white"
          }`}
        >
          {isBotActive ? "🔴 NONAKTIFKAN BOT (KILL SWITCH)" : "🟢 AKTIFKAN BOT OTOMATIS"}
        </button>
      </div>

      {/* INDIKATOR STATUS PERFORMA */}
      <div className="grid grid-cols-2 gap-4 mb-4 text-center font-mono">
        <div className="bg-[#1c2030] p-2 rounded border border-gray-800">
          <div className="text-[10px] text-gray-500">STATUS MESIN</div>
          <div className={`text-sm font-bold ${isBotActive ? "text-emerald-400 animate-pulse" : "text-gray-400"}`}>
            {isBotActive ? "RUNNING (AUTO)" : "IDLE (MANUAL)"}
          </div>
        </div>
        <div className="bg-[#1c2030] p-2 rounded border border-gray-800">
          <div className="text-[10px] text-gray-500">RISK LIMIT PER TRADE</div>
          <div className="text-sm font-bold text-white">10 LOT / ORDER</div>
        </div>
      </div>

      {/* DAFTAR LOG EKSEKUSI REAL-TIME BURSA */}
      <h4 className="text-[10px] font-bold text-gray-500 uppercase tracking-wider mb-2">Live Order Book Execution Logs</h4>
      <div className="bg-[#0c0d14] rounded p-2 h-32 overflow-y-auto border border-gray-900 font-mono text-[11px] space-y-1.5">
        {orderLogs.length > 0 ? (
          orderLogs.map(log => (
            <div key={log.id} className="flex justify-between border-b border-gray-900 pb-1 text-gray-400">
              <span className="text-gray-600">[{log.time}]</span>
              <span className={log.side === "BUY" ? "text-emerald-400" : "text-red-400"}>{log.side}</span>
              <span className="text-white font-bold">{log.ticker}</span>
              <span>@{log.price}</span>
              <span className="text-blue-400 font-semibold">{log.status}</span>
            </div>
          ))
        ) : (
          <div className="text-gray-600 text-center pt-8">Belum ada order otomatis yang dieksekusi oleh mesin.</div>
        )}
      </div>
    </div>
  );
}
