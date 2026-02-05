"use client";

import { useState, useEffect } from "react";
import { Save, Shield, Layout, ListChecks } from "lucide-react";
import axios from "axios";
import toast from "react-hot-toast";
import api from "@/lib/api";

const PAYMENT_METHODS = [
  { id: "bca_va", name: "BCA Virtual Account", category: "Bank Transfer" },
  { id: "bni_va", name: "BNI Virtual Account", category: "Bank Transfer" },
  { id: "bri_va", name: "BRI Virtual Account", category: "Bank Transfer" },
  { id: "mandiri_va", name: "Mandiri Bill Payment", category: "Bank Transfer" },
  { id: "permata_va", name: "Permata Virtual Account", category: "Bank Transfer" },
  { id: "qris", name: "QRIS (Gopay, OVO, Dana, LinkAja)", category: "E-Wallet & QR" },
  { id: "gopay", name: "GoPay (Deeplink)", category: "E-Wallet & QR" },
  { id: "shopeepay", name: "ShopeePay", category: "E-Wallet & QR" },
];

export default function AdminPaymentSettings() {
  const [loading, setLoading] = useState(true);
  const [mode, setMode] = useState("SNAP");
  const [activeMethods, setActiveMethods] = useState<string[]>([]);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const { data } = await api.get("/admin/payment-settings");
      setMode(data.mode);
      setActiveMethods(data.activeMethods || []);
    } catch (error) {
      toast.error("Gagal mengambil pengaturan");
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      await api.post("/admin/payment-settings", {
        mode,
        activeMethods,
      });
      toast.success("Pengaturan berhasil disimpan");
    } catch (error) {
      toast.error("Gagal menyimpan pengaturan");
    }
  };

  const toggleMethod = (id: string) => {
    if (activeMethods.includes(id)) {
      setActiveMethods(activeMethods.filter((m) => m !== id));
    } else {
      setActiveMethods([...activeMethods, id]);
    }
  };

  if (loading) return <div className="p-8 text-center">Memuat...</div>;

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <Shield className="text-blue-600" /> Pengaturan Pembayaran
          </h1>
          <p className="text-gray-500 text-sm">Kelola bagaimana pelanggan membayar pesanan</p>
        </div>
        <button
          onClick={handleSave}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center gap-2 transition-all shadow-sm"
        >
          <Save size={18} /> Simpan Perubahan
        </button>
      </div>

      <div className="grid gap-6">
        {/* Mode Selection */}
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Layout size={20} className="text-gray-400" /> Mode Integrasi Midtrans
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <button
              onClick={() => setMode("SNAP")}
              className={`p-4 rounded-xl border-2 text-left transition-all ${
                mode === "SNAP"
                  ? "border-blue-500 bg-blue-50"
                  : "border-gray-100 hover:border-gray-200"
              }`}
            >
              <div className="font-bold text-gray-900">Snap Popup</div>
              <div className="text-xs text-gray-500">Gunakan antarmuka pembayaran bawaan Midtrans (Popup/Redirect).</div>
            </button>
            <button
              onClick={() => setMode("CORE")}
              className={`p-4 rounded-xl border-2 text-left transition-all ${
                mode === "CORE"
                  ? "border-blue-500 bg-blue-50"
                  : "border-gray-100 hover:border-gray-200"
              }`}
            >
              <div className="font-bold text-gray-900">Core API (Direct)</div>
              <div className="text-xs text-gray-500">Integrasi penuh di dalam website Anda. Kontrol penuh atas UI pembayaran.</div>
            </button>
          </div>
        </div>

        {/* Methods Selection (Only for CORE) */}
        {mode === "CORE" && (
          <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm animate-in fade-in slide-in-from-top-4 duration-300">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <ListChecks size={20} className="text-gray-400" /> Metode Pembayaran Aktif
            </h2>
            <p className="text-sm text-gray-500 mb-6">Pilih metode pembayaran yang ingin Anda aktifkan untuk Core API.</p>
            
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {PAYMENT_METHODS.map((method) => (
                <label
                  key={method.id}
                  className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all ${
                    activeMethods.includes(method.id)
                      ? "border-blue-200 bg-blue-50/50"
                      : "border-gray-100 hover:bg-gray-50"
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={activeMethods.includes(method.id)}
                    onChange={() => toggleMethod(method.id)}
                    className="w-4 h-4 text-blue-600 rounded"
                  />
                  <div>
                    <div className="text-sm font-medium text-gray-900">{method.name}</div>
                    <div className="text-[10px] text-gray-400 uppercase tracking-wider">{method.category}</div>
                  </div>
                </label>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
