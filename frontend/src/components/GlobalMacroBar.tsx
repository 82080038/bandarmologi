"use client";

import { useState } from "react";

interface GlobalIndex {
  name: string;
  price: string;
  change: string;
  safe: boolean;
}

export default function GlobalMacroBar() {
  // Dalam produksi, data ini di-fetch berkala dari endpoint /api/global-sentiment
  const [globalIndices, setGlobalIndices] = useState<GlobalIndex[]>([
    { name: "S&P 500 (US)", price: "5.450", change: "+0.45%", safe: true },
    { name: "NASDAQ (US)", price: "19.120", change: "-0.12%", safe: true },
    { name: "USD/IDR", price: "16.120", change: "+0.05%", safe: true },
    { name: "Foreign Flow IHSG", price: "Net Buy", change: "+Rp 420B", safe: true }
  ]);

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
      {globalIndices.map((idx) => (
        <div key={idx.name} className="bg-[#131722] border border-gray-800 rounded p-3 flex justify-between items-center font-mono">
          <div>
            <span className="text-[10px] text-gray-500 block uppercase font-sans font-bold">{idx.name}</span>
            <span className="text-sm font-bold text-white">{idx.price}</span>
          </div>
          <span className={`text-xs font-bold px-2 py-0.5 rounded ${
            idx.change.startsWith("+") ? "text-emerald-400 bg-emerald-500/5" : "text-red-400 bg-red-500/5"
          }`}>
            {idx.change}
          </span>
        </div>
      ))}
    </div>
  );
}
