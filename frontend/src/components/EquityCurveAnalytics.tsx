"use client";

import { useEffect, useState } from "react";

interface AnalyticsData {
  date: string;
  total_equity: number;
  daily_pnl: number;
  daily_pnl_percent: number;
  total_trades: number;
  winning_trades: number;
  losing_trades: number;
  win_rate: number;
  profit_factor: number;
  max_drawdown: number;
}

interface AnalyticsResponse {
  analytics: AnalyticsData[];
  count: number;
}

export default function EquityCurveAnalytics() {
  const [analytics, setAnalytics] = useState<AnalyticsData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchAnalytics() {
      try {
        const res = await fetch("http://localhost:8000/api/equity-analytics");
        const data: AnalyticsResponse = await res.json();
        setAnalytics(data.analytics);
      } catch (err) {
        console.error("Gagal mengambil data analytics", err);
      } finally {
        setLoading(false);
      }
    }
    fetchAnalytics();
    const interval = setInterval(fetchAnalytics, 60000); // Update setiap 1 menit
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="bg-[#131722] p-4 rounded-lg border border-gray-800">
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">
          📊 EQUITY CURVE ANALYTICS
        </h3>
        <div className="text-gray-500 text-xs">Memuat data performa...</div>
      </div>
    );
  }

  if (analytics.length === 0) {
    return (
      <div className="bg-[#131722] p-4 rounded-lg border border-gray-800">
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">
          📊 EQUITY CURVE ANALYTICS
        </h3>
        <div className="text-gray-500 text-xs">Belum ada data performa tersedia.</div>
      </div>
    );
  }

  const latest = analytics[0];
  const totalEquity = latest.total_equity;
  const totalPnL = analytics.reduce((sum, a) => sum + a.daily_pnl, 0);
  const avgWinRate = analytics.reduce((sum, a) => sum + a.win_rate, 0) / analytics.length;
  const avgProfitFactor = analytics.reduce((sum, a) => sum + a.profit_factor, 0) / analytics.length;

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-gray-800">
      <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">
        📊 EQUITY CURVE ANALYTICS
      </h3>
      
      {/* Summary Metrics */}
      <div className="grid grid-cols-2 gap-2 mb-3">
        <div className="bg-[#0c0d14] p-2 rounded border border-gray-900">
          <div className="text-[10px] text-gray-500">TOTAL EQUITY</div>
          <div className="text-sm font-bold font-mono text-white">
            Rp {totalEquity.toLocaleString("id-ID", { minimumFractionDigits: 0 })}
          </div>
        </div>
        <div className="bg-[#0c0d14] p-2 rounded border border-gray-900">
          <div className="text-[10px] text-gray-500">TOTAL P&L</div>
          <div className={`text-sm font-bold font-mono ${totalPnL >= 0 ? 'text-emerald-400' : 'text-red-400'}`}>
            Rp {totalPnL.toLocaleString("id-ID", { minimumFractionDigits: 0 })}
          </div>
        </div>
        <div className="bg-[#0c0d14] p-2 rounded border border-gray-900">
          <div className="text-[10px] text-gray-500">WIN RATE</div>
          <div className="text-sm font-bold font-mono text-emerald-400">
            {(avgWinRate * 100).toFixed(1)}%
          </div>
        </div>
        <div className="bg-[#0c0d14] p-2 rounded border border-gray-900">
          <div className="text-[10px] text-gray-500">PROFIT FACTOR</div>
          <div className="text-sm font-bold font-mono text-blue-400">
            {avgProfitFactor.toFixed(2)}
          </div>
        </div>
      </div>

      {/* Recent Performance Table */}
      <div className="max-h-32 overflow-y-auto">
        <table className="w-full text-[10px]">
          <thead className="text-gray-500 font-mono">
            <tr>
              <th className="text-left pb-1">DATE</th>
              <th className="text-right pb-1">EQUITY</th>
              <th className="text-right pb-1">P&L %</th>
              <th className="text-right pb-1">TRADES</th>
            </tr>
          </thead>
          <tbody className="font-mono">
            {analytics.map((a, idx) => (
              <tr key={idx} className="border-t border-gray-900">
                <td className="py-1 text-gray-400">{a.date}</td>
                <td className="py-1 text-right text-white">
                  Rp {a.total_equity.toLocaleString("id-ID", { minimumFractionDigits: 0 })}
                </td>
                <td className={`py-1 text-right ${a.daily_pnl_percent >= 0 ? 'text-emerald-400' : 'text-red-400'}`}>
                  {a.daily_pnl_percent >= 0 ? '+' : ''}{a.daily_pnl_percent.toFixed(2)}%
                </td>
                <td className="py-1 text-right text-gray-400">{a.total_trades}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
