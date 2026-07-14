"use client";

import { useState } from "react";

interface StressTestingPanelProps {
  ticker: string;
}

export default function StressTestingPanel({ ticker }: StressTestingPanelProps) {
  const [testingStatus, setTestingStatus] = useState("READY TO SIMULATE");
  const [isCrashedMode, setIsCrashedMode] = useState(false);

  const triggerStressTest = async (scenarioName: string) => {
    setTestingStatus(`EXECUTING ${scenarioName}...`);
    setIsCrashedMode(true);
    
    try {
      const res = await fetch(`http://localhost:8000/api/stress-test?ticker=${ticker}&scenario=${scenarioName}`);
      const data = await res.json();
      setTestingStatus(data.message);
    } catch (err) {
      setTestingStatus("SIMULATION FAILED TO EXECUTE");
    }
  };

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-red-900/30 shadow-[0_0_15px_rgba(220,38,38,0.05)]">
      <h3 className="text-xs font-bold text-red-400 uppercase tracking-wider mb-2 flex items-center gap-1.5">
        ⚠️ REGULATORY SHIELD & STRESS TESTING TERMINAL
      </h3>
      <p className="text-gray-400 text-[11px] mb-4 font-sans leading-relaxed">
        Gunakan konsol ini untuk menyuntikkan skenario krisis buatan secara langsung guna menguji sistem manajemen risiko bot trading Anda.
      </p>

      {/* INDIKATOR STATUS PERTAHANAN */}
      <div className="bg-[#0c0d14] rounded p-3 border border-gray-900 mb-4 font-mono text-xs flex justify-between items-center">
        <span className="text-gray-500">SIMULATOR ENGINE STATUS:</span>
        <span className={`font-bold ${isCrashedMode ? "text-amber-500 animate-pulse" : "text-emerald-400"}`}>
          {testingStatus}
        </span>
      </div>

      {/* TOMBOL AKSI PICU KRISIS */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <button
          onClick={() => triggerStressTest("SYSTEMIC_GLOBAL_PANIC")}
          className="bg-red-900/20 hover:bg-red-900/40 text-red-200 border border-red-700/30 py-2 rounded text-xs font-bold font-mono transition-all"
        >
          💥 REPLIKA KRISIS GLOBAL (PANIC SELL)
        </button>
        <button
          onClick={() => {
            setIsCrashedMode(false);
            setTestingStatus("READY TO SIMULATE");
          }}
          className="bg-gray-800 hover:bg-gray-700 text-gray-300 py-2 rounded text-xs font-bold transition-all"
        >
          🔄 RESET KE DATA REAL-TIME BURSA
        </button>
      </div>
    </div>
  );
}
