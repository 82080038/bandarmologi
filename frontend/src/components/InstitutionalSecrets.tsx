"use client";

import { useEffect, useState } from "react";

interface InstitutionalSecretsProps {
  ticker: string;
  currentPrice: number;
}

interface SecretsData {
  ticker: string;
  iceberg_intelligence: {
    status: string;
    price?: number;
    visible_lot?: number;
    actual_executed_lot?: number;
    multiplier?: number;
  };
  dark_pool_crossing: {
    manipulation_risk: string;
    reason?: string;
    instruction?: string;
  };
  pre_closing_markup: {
    status: string;
    type?: string;
    volume_surge_factor?: number;
    action_plan?: string;
  };
}

export default function InstitutionalSecrets({ ticker, currentPrice }: InstitutionalSecretsProps) {
  const [secretsData, setSecretsData] = useState<SecretsData | null>(null);

  useEffect(() => {
    async function fetchSecrets() {
      try {
        const res = await fetch(`http://localhost:8000/api/institutional-secrets/${ticker}?current_price=${currentPrice}`);
        const data = await res.json();
        setSecretsData(data);
      } catch (err) {
        console.error("Gagal memuat modul data rahasia bursa", err);
      }
    }
    fetchSecrets();
    const interval = setInterval(fetchSecrets, 2000); // Tarik data rahasia bursa per 2 detik
    return () => clearInterval(interval);
  }, [ticker, currentPrice]);

  if (!secretsData) return <div className="text-gray-600 text-xs animate-pulse">Mengaktifkan modul intelijen bursa...</div>;

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-purple-900/30 shadow-[0_0_15px_rgba(147,51,234,0.05)]">
      <h3 className="text-xs font-bold text-purple-400 uppercase tracking-wider mb-3 flex items-center gap-1">
        🔮 INSTITUTIONAL ALGO & DARK FLOW INTELLIGENCE
      </h3>
      
      <div className="space-y-3 font-mono text-[11px]">
        {/* WIDGET 1: ICEBERG DETECTOR */}
        <div className="p-2.5 rounded bg-[#0c0d14] border border-gray-900">
          <div className="text-gray-500 font-sans font-bold text-[10px]">1. ICEBERG ORDER DETECTION</div>
          {secretsData.iceberg_intelligence.status === "ICEBERG_DETECTED" ? (
            <div className="mt-1 text-purple-400 animate-pulse font-bold">
              ⚠️ DETEKSI GUNUNG ES DI RP {secretsData.iceberg_intelligence.price}! Volume Asli: {secretsData.iceberg_intelligence.actual_executed_lot?.toLocaleString()} Lot ({secretsData.iceberg_intelligence.multiplier}x Lipat Antrean Visual).
            </div>
          ) : (
            <div className="mt-1 text-gray-400">Status: Tidak ada manipulasi dinding transaksi tersembunyi.</div>
          )}
        </div>

        {/* WIDGET 2: CROSSING SAHAM */}
        <div className="p-2.5 rounded bg-[#0c0d14] border border-gray-900">
          <div className="text-gray-500 font-sans font-bold text-[10px]">2. DARK POOL CROSSING FILTER (PASAR NEGOSIASI)</div>
          {secretsData.dark_pool_crossing.manipulation_risk === "HIGH" ? (
            <div className="mt-1 text-amber-400">
              ⚠️ RISIKO TINGGI: {secretsData.dark_pool_crossing.reason} <span className="text-white underline">{secretsData.dark_pool_crossing.instruction}</span>
            </div>
          ) : (
            <div className="mt-1 text-gray-400">Status: Distribusi barang lewat pasar negosiasi terpantau aman.</div>
          )}
        </div>

        {/* WIDGET 3: PRE-CLOSING MARKUP */}
        <div className="p-2.5 rounded bg-[#0c0d14] border border-gray-900">
          <div className="text-gray-500 font-sans font-bold text-[10px]">3. PRE-CLOSING KOSMETIK GRAFIK (MARK-UP)</div>
          {secretsData.pre_closing_markup.status === "MANIPULATION_DETECTED" ? (
            <div className="mt-1 text-red-400 font-bold">
              ⚠️ MARK-UP TERDETEKSI: Volume penutupan melonjak {secretsData.pre_closing_markup.volume_surge_factor}x lipat! {secretsData.pre_closing_markup.action_plan}
            </div>
          ) : (
            <div className="mt-1 text-gray-500 italic">
              Status: Menunggu Sesi Penutupan Bursa Pasar Saham Indonesia (15.50 WIB).
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
