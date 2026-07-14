"use client";

import { useState } from "react";
import RealTimeChart from "@/components/RealTimeChart";
import MatrixView from "@/components/MatrixView";
import BotController from "@/components/BotController";
import GlobalMacroBar from "@/components/GlobalMacroBar";
import StressTestingPanel from "@/components/StressTestingPanel";
import InstitutionalSecrets from "@/components/InstitutionalSecrets";
import BotAuditLogs from "@/components/BotAuditLogs";
import NotificationToast from "@/components/NotificationToast";
import VirtualAccountWidget from "@/components/VirtualAccountWidget";
import CapitalController from "@/components/CapitalController";
import BotTimeStatusWidget from "@/components/BotTimeStatusWidget";
import EquityCurveAnalytics from "@/components/EquityCurveAnalytics";

export default function AdvancedDashboard() {
  // Daftar saham satu sektor yang ingin dipantau bersamaan
  const [sectorTickers, setSectorTickers] = useState(["BBCA", "BBRI", "BMRI", "BBNI"]);
  const [selectedTicker, setSelectedTicker] = useState("BBCA");

  const handleDownloadPDF = async () => {
    try {
      // Membuka tautan unduhan API secara langsung di tab baru browser
      window.open(`http://localhost:8000/api/report/pdf/${selectedTicker}`, "_blank");
    } catch (error) {
      console.error("Gagal mengunduh laporan PDF:", error);
      alert("Gagal memproses pembuatan laporan PDF.");
    }
  };

  return (
    <div className="min-h-screen bg-[#0c0d14] text-white p-6">
      {/* Header Aplikasi */}
      <header className="mb-6 flex justify-between items-center border-b border-gray-800 pb-4">
        <div>
          <h1 className="text-xl font-black text-emerald-400 tracking-tight">SMART MONEY INSTITUTIONAL TERMINAL</h1>
          <p className="text-gray-400 text-xs">Sistem Analisis Deteksi Manipulasi Penggerak Pasar Saham</p>
        </div>
        <div className="flex items-center gap-4">
          <button
            onClick={handleDownloadPDF}
            className="flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white font-bold text-xs px-4 py-2 rounded transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            EKSPOR LAPORAN (PDF)
          </button>
          <NotificationToast />
          <BotTimeStatusWidget />
          <div className="text-xs font-mono text-gray-500">
            Sistem Terkoneksi: <span className="text-emerald-400">TimescaleDB API v2</span>
          </div>
        </div>
      </header>

      {/* GLOBAL MACRO SENTIMENT BAR */}
      <GlobalMacroBar />

      {/* Grid Utama Layout */}
      <div className="space-y-6">
        
        {/* BAGIAN ATAS: MULTI-TICKER MATRIX VIEW */}
        <div className="w-full">
          <MatrixView 
            tickers={sectorTickers} 
            onSelectTicker={(ticker) => setSelectedTicker(ticker)} 
          />
        </div>

        {/* BAGIAN BAWAH: DETAIL CHART SAHAM YANG DIKLIK */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-[#131722] p-4 rounded-lg border border-gray-800">
            <div className="flex justify-between items-center mb-3">
              <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider">
                Fokus Analisis Teknikal Grafik: <span className="text-emerald-400 text-sm font-mono">{selectedTicker}</span>
              </h3>
            </div>
            {/* Grafik akan re-render otomatis setiap selectedTicker berubah */}
            <RealTimeChart key={selectedTicker} ticker={selectedTicker} />
          </div>

          {/* PANEL KANAN: RIWAYAT NOTIFIKASI MANIPULASI */}
          <div className="space-y-4">
            <div className="bg-[#131722] p-4 rounded-lg border border-gray-800 flex flex-col">
              <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider border-b border-gray-800 pb-2 mb-3">
                LIVE RISK & MANIPULATION ALERTS
              </h3>
              <div className="flex-1 space-y-3 overflow-y-auto max-h-[180px] pr-2">
                {/* Logika Notifikasi Spoofing */}
                <div className="bg-amber-500/5 border border-amber-500/20 p-3 rounded text-xs">
                  <div className="flex justify-between text-amber-400 font-bold mb-1">
                    <span>[SPOOFING ALERT]</span>
                    <span>BARU JALAN</span>
                  </div>
                  <p className="text-gray-300">Deteksi dinding antrean palsu dicabut sebesar <span className="font-mono font-bold text-white">8.500 Lot</span> di saham {selectedTicker}.</p>
                </div>
                <div className="bg-emerald-500/5 border border-emerald-500/10 p-3 rounded text-xs text-gray-500">
                  Belum ada manipulasi transaksi berisiko tinggi lainnya terdeteksi pada sektor ini dalam 15 menit terakhir.
                </div>
              </div>
            </div>
            
            {/* BOT CONTROLLER PANEL */}
            <BotController ticker={selectedTicker} />
            
            {/* STRESS TESTING PANEL */}
            <StressTestingPanel ticker={selectedTicker} />
            
            {/* INSTITUTIONAL SECRETS PANEL */}
            <InstitutionalSecrets ticker={selectedTicker} currentPrice={5000} />
            
            {/* BOT AUDIT LOGS PANEL */}
            <BotAuditLogs />
            
            {/* VIRTUAL ACCOUNT WIDGET */}
            <VirtualAccountWidget />
            
            {/* CAPITAL CONTROLLER */}
            <CapitalController />
            
            {/* EQUITY CURVE ANALYTICS */}
            <EquityCurveAnalytics />
          </div>
        </div>

      </div>
    </div>
  );
}
