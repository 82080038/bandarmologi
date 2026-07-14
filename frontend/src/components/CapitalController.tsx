"use client";

import { useState } from "react";

export default function CapitalController() {
  const [isResetting, setIsResetting] = useState(false);

  const handleResetCapital = async (amount: number) => {
    const confirmAction = window.confirm(`Apakah Anda yakin ingin mengosongkan portofolio saat ini dan mengubah modal awal ke Rp ${amount.toLocaleString("id-ID")}?`);
    if (!confirmAction) return;

    setIsResetting(true);
    try {
      const res = await fetch(`http://localhost:8000/api/virtual-account/reset?initial_capital=${amount}`, {
        method: "POST"
      });
      const data = await res.json();
      if (data.status === "SUCCESS") {
        alert("Konfigurasi modal simulasi berhasil diubah!");
      }
    } catch (err) {
      console.error("Gagal mengubah parameter kapital", err);
      alert("Terjadi kegagalan jaringan saat menyetel ulang modal.");
    } finally {
      setIsResetting(false);
    }
  };

  return (
    <div className="bg-[#131722] p-4 rounded-lg border border-gray-800">
      <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">
        ⚙️ CAPITAL PARAMETER CONFIGURATION (SANDBOX CONTROLLER)
      </h3>
      <p className="text-gray-400 text-[11px] mb-3 font-sans leading-relaxed">
        Pilih atau ubah kapasitas likuiditas modal virtual yang akan digunakan oleh Robot untuk simulasi otomatisasi diversifikasi di IHSG.
      </p>

      <div className="grid grid-cols-2 gap-3">
        <button
          disabled={isResetting}
          onClick={() => handleResetCapital(500000000)}
          className="bg-purple-600/20 hover:bg-purple-600/40 text-purple-300 border border-purple-500/30 py-2 rounded text-xs font-bold font-mono transition-all disabled:opacity-50"
        >
          💰 SET Rp 500 JUTA
        </button>
        <button
          disabled={isResetting}
          onClick={() => handleResetCapital(1000000000)}
          className="bg-blue-600/20 hover:bg-blue-600/40 text-blue-300 border border-blue-500/30 py-2 rounded text-xs font-bold font-mono transition-all disabled:opacity-50"
        >
          🏦 SET Rp 1 MILIAR
        </button>
      </div>
    </div>
  );
}
