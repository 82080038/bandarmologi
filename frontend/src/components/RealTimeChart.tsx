"use client";

import { useEffect, useRef } from "react";
import { createChart, CrosshairMode } from "lightweight-charts";

export default function RealTimeChart({ ticker }: { ticker: string }) {
  const chartContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!chartContainerRef.current) return;

    // 1. Inisialisasi Chart Standar Profesional
    const chart = createChart(chartContainerRef.current, {
      width: chartContainerRef.current.clientWidth,
      height: 450,
      layout: {
        background: { color: "#131722" }, // Tema Gelap Khas TradingView
        textColor: "#d1d4dc",
      },
      grid: {
        vertLines: { color: "rgba(42, 46, 57, 0.5)" },
        horzLines: { color: "rgba(42, 46, 57, 0.5)" },
      },
      crosshair: { mode: CrosshairMode.Normal },
      rightPriceScale: { borderColor: "rgba(197, 203, 206, 0.8)" },
      timeScale: { borderColor: "rgba(197, 203, 206, 0.8)", timeVisible: true },
    });

    // 2. Tambahkan Candlestick Series
    const candleSeries = chart.addCandlestickSeries({
      upColor: "#26a69a",
      downColor: "#ef5350",
      borderVisible: false,
      wickUpColor: "#26a69a",
      wickDownColor: "#ef5350",
    });

    // 3. Tambahkan Volume Series di Panel Bawah
    const volumeSeries = chart.addHistogramSeries({
      color: "#26a69a",
      priceFormat: { type: "volume" },
      priceScaleId: "", // Letakkan di sub-panel bawah
    });
    
    chart.priceScale("").setOptions({
      scaleMargins: { top: 0.8, bottom: 0 },
    });

    // 4. Mengambil data average harga modal gabungan dari API Backend Python
    fetch(`http://localhost:8000/api/market-maker-avg/${ticker}`)
      .then(res => res.json())
      .then(data => {
        if (data.combined_market_maker_avg) {
          // Membuat Garis Horizontal Otomatis di Chart
          candleSeries.createPriceLine({
            price: data.combined_market_maker_avg,
            color: '#e91e63', // Warna Pink/Merah Terang Profesional
            lineWidth: 2,
            lineStyle: 2, // Tipe Garis Putus-putus (Dashed)
            axisLabelVisible: true,
            title: `MODAL BANDAR: ${data.combined_market_maker_avg}`,
          });
        }
      });

    // 5. Hubungkan ke WebSocket Python Backend
    const ws = new WebSocket(`ws://localhost:8000/ws/trades/${ticker.toLowerCase()}`);

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      
      // Parse string waktu menjadi timestamp unix detik
      const unixTimestamp = Math.floor(new Date(data.time).getTime() / 1000);

      // Perbarui Grafik Candlestick
      candleSeries.update({
        time: unixTimestamp,
        open: data.open,
        high: data.high,
        low: data.low,
        close: data.close,
      });

      // Perbarui Grafik Batang Volume
      volumeSeries.update({
        time: unixTimestamp,
        value: data.volume,
        color: data.close >= data.open ? "rgba(38, 166, 154, 0.5)" : "rgba(239, 83, 80, 0.5)",
      });
    };

    // Responsif terhadap perubahan ukuran layar browser
    const handleResize = () => {
      chart.applyOptions({ width: chartContainerRef.current.clientWidth });
    };
    window.addEventListener("resize", handleResize);

    return () => {
      ws.close();
      window.removeEventListener("resize", handleResize);
      chart.remove();
    };
  }, [ticker]);

  return <div ref={chartContainerRef} className="w-full rounded-lg overflow-hidden border border-gray-800" />;
}
