"use client";

import { useEffect, useState } from "react";

interface Holding {
  ticker: string;
  avg_buy_price: number;
  current_lot_qty: number;
}

interface VirtualAccountData {
  cash_balance: number;
  holdings: Holding[];
}

export default function VirtualAccountWidget() {
  const [balance, setBalance] = useState(0);
  const [portfolio, setPortfolio] = useState<Holding[]>([]);

  useEffect(() => {
    async function fetchVirtualData() {
      // Endpoint ini menarik data hasil join tabel virtual_account dan virtual_portfolio
      const res = await fetch("http://localhost:8000/api/virtual-account-status");
      const data: VirtualAccountData = await res.json();
      setBalance(data.cash_balance);
      setPortfolio(data.holdings);
    }
    fetchVirtualData();
    const interval = setInterval(fetchVirtualData, 2000); // Sinkronisasi saldo per 2 detik
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-emerald-900/30">
      <div className="flex justify-between items-center border-b border-gray-800 pb-2 mb-3">
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider">💳 Rekening Dana Virtual (Paper Account)</h3>
        <span className="text-[10px] bg-emerald-500/10 text-emerald-400 font-bold px-1.5 py-0.5 rounded font-mono">Sandbox Mode</span>
      </div>
      
      {/* Sisa Uang Tunai */}
      <div className="mb-4">
        <span className="text-[10px] text-gray-500 block">SISA CASH VIRTUAL (IDR)</span>
        <span className="text-xl font-bold font-mono text-white">
          Rp {balance.toLocaleString("id-ID", { minimumFractionDigits: 2 })}
        </span>
      </div>

      {/* Saham Terbeli */}
      <h4 className="text-[10px] font-bold text-gray-500 uppercase tracking-wider mb-2">Saham dalam Genggaman Bot</h4>
      <div className="space-y-1.5 max-h-32 overflow-y-auto">
        {portfolio.length > 0 ? (
          portfolio.map(stock => (
            <div key={stock.ticker} className="flex justify-between items-center bg-[#0c0d14] p-2 rounded text-xs border border-gray-900 font-mono">
              <span className="text-emerald-400 font-bold font-sans">{stock.ticker}</span>
              <span className="text-gray-400">{stock.current_lot_qty} Lot</span>
              <span className="text-white">Avg: Rp {Math.round(stock.avg_buy_price).toLocaleString("id-ID")}</span>
            </div>
          ))
        ) : (
          <div className="text-gray-600 text-center py-4 text-[11px]">Sistem kas kosong. Bot belum mendeteksi akumulasi bandar.</div>
        )}
      </div>
    </div>
  );
}
