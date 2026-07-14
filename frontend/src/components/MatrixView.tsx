"use client";

import { useEffect, useState } from "react";

interface MatrixData {
  ticker: string;
  last_price: number;
  volume_lot: number;
  smart_money_flow: number;
  status: string;
  spoofing_alert: boolean;
}

interface MatrixViewProps {
  tickers: string[];
  onSelectTicker: (ticker: string) => void;
}

export default function MatrixView({ tickers, onSelectTicker }: MatrixViewProps) {
  const [data, setData] = useState<MatrixData[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchMatrixData = async () => {
    try {
      const res = await fetch(`http://localhost:8000/api/matrix?tickers=${tickers.join(",")}`);
      const matrixData = await res.json();
      setData(matrixData);
      setLoading(false);
    } catch (error) {
      console.error("Gagal memuat data matriks:", error);
    }
  };

  useEffect(() => {
    fetchMatrixData();
    const interval = setInterval(fetchMatrixData, 3000); // Sinkronisasi data setiap 3 detik
    return () => clearInterval(interval);
  }, [tickers]);

  if (loading) return <div className="text-gray-500 animate-pulse text-sm">Memuat matriks pergerakan bandar...</div>;

  return (
    <div className="bg-[#131722] border border-gray-800 rounded-lg overflow-hidden">
      <div className="p-4 border-b border-gray-800 flex justify-between items-center">
        <h2 className="text-sm font-bold tracking-wider text-gray-400">SMART MONEY SECTOR MATRIX VIEW</h2>
        <span className="text-xs bg-emerald-500/10 text-emerald-400 px-2 py-0.5 rounded animate-pulse">Live Feed</span>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse text-xs font-mono">
          <thead>
            <tr className="border-b border-gray-800 text-gray-500 uppercase tracking-wider bg-[#1c2030]/50">
              <th className="p-3">KODE</th>
              <th className="p-3 text-right">HARGA TERAKHIR</th>
              <th className="p-3 text-right">VOL (LOT)</th>
              <th className="p-3 text-right">NET MONEY FLOW</th>
              <th className="p-3 text-center">STATUS BANDAR</th>
              <th className="p-3 text-center">SPOOFING ALERT</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-800/50">
            {data.map((row) => {
              const isAcc = row.status.includes("ACCUMULATION");
              const isDist = row.status.includes("DISTRIBUTION");
              
              return (
                <tr 
                  key={row.ticker} 
                  onClick={() => onSelectTicker(row.ticker)}
                  className="hover:bg-[#1c2030]/40 cursor-pointer transition-colors"
                >
                  <td className="p-3 font-bold text-white text-sm">{row.ticker}</td>
                  <td className="p-3 text-right font-semibold">{row.last_price.toLocaleString("id-ID")}</td>
                  <td className="p-3 text-right text-gray-400">{row.volume_lot.toLocaleString("id-ID")}</td>
                  <td className={`p-3 text-right font-bold ${row.smart_money_flow >= 0 ? "text-emerald-400" : "text-red-400"}`}>
                    {row.smart_money_flow > 0 ? `+${row.smart_money_flow}` : row.smart_money_flow}%
                  </td>
                  <td className="p-3 text-center">
                    <span className={`px-2 py-0.5 rounded font-sans font-bold text-[10px] ${
                      isAcc ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" :
                      isDist ? "bg-red-500/10 text-red-400 border border-red-500/20" :
                      "bg-gray-500/10 text-gray-400"
                    }`}>
                      {row.status}
                    </span>
                  </td>
                  <td className="p-3 text-center">
                    {row.spoofing_alert ? (
                      <span className="inline-block w-2 h-2 rounded-full bg-amber-500 animate-ping shadow-[0_0_8px_#f59e0b]" title="Indikasi pencabutan bid/ask palsu terdeteksi!" />
                    ) : (
                      <span className="inline-block w-2 h-2 rounded-full bg-gray-700" />
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
