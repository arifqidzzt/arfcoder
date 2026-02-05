'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { CreditCard, Monitor, Smartphone, Settings, Save } from 'lucide-react';

export default function PaymentSettingsPage() {
  const [loading, setLoading] = useState(true);
  const [methods, setMethods] = useState<any[]>([]);
  const [mode, setMode] = useState('SNAP');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      // 1. Fetch Config
      const configRes = await api.get('/admin/config');
      const modeConfig = configRes.data.find((c: any) => c.key === 'payment_gateway_mode');
      if (modeConfig) setMode(modeConfig.value);

      // 2. Fetch Methods
      const methodRes = await api.get('/admin/payment-methods');
      setMethods(methodRes.data);
    } catch (error) {
      toast.error('Gagal memuat pengaturan pembayaran');
    } finally {
      setLoading(false);
    }
  };

  const handleSaveMode = async () => {
    try {
      await api.post('/admin/config', { key: 'payment_gateway_mode', value: mode });
      toast.success('Mode pembayaran disimpan');
    } catch (error) {
      toast.error('Gagal menyimpan mode');
    }
  };

  const handleToggleMethod = async (id: string) => {
    try {
      await api.put(`/admin/payment-methods/${id}/toggle`, {});
      setMethods(methods.map(m => m.id === id ? { ...m, isActive: !m.isActive } : m));
      toast.success('Status metode pembayaran diubah');
    } catch (error) {
      toast.error('Gagal mengubah status');
    }
  };

  if (loading) return <div className="p-8 text-center">Memuat pengaturan...</div>;

  return (
    <div className="p-6 md:p-8 max-w-5xl mx-auto space-y-6">
      <h1 className="text-2xl font-bold tracking-tight mb-6">Pengaturan Pembayaran</h1>

      {/* MODE SELECTION */}
      <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
        <h2 className="text-lg font-bold mb-4 flex items-center gap-2">
            <Settings size={20} /> Mode Payment Gateway
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div 
                onClick={() => setMode('SNAP')}
                className={`p-4 border rounded-xl cursor-pointer transition-all flex items-center gap-4 ${mode === 'SNAP' ? 'border-black bg-gray-50 ring-1 ring-black' : 'border-gray-200 hover:border-gray-300'}`}
            >
                <div className="p-3 bg-blue-100 rounded-full text-blue-600">
                    <Monitor size={24} />
                </div>
                <div>
                    <h3 className="font-bold">Midtrans SNAP (Pop-up)</h3>
                    <p className="text-xs text-gray-500 mt-1">Pembayaran muncul sebagai Pop-up / Redirect otomatis. User memilih metode di halaman Midtrans.</p>
                </div>
                {mode === 'SNAP' && <div className="w-3 h-3 rounded-full bg-black ml-auto"></div>}
            </div>

            <div 
                onClick={() => setMode('CORE')}
                className={`p-4 border rounded-xl cursor-pointer transition-all flex items-center gap-4 ${mode === 'CORE' ? 'border-black bg-gray-50 ring-1 ring-black' : 'border-gray-200 hover:border-gray-300'}`}
            >
                <div className="p-3 bg-purple-100 rounded-full text-purple-600">
                    <Smartphone size={24} />
                </div>
                <div>
                    <h3 className="font-bold">Core API (Custom UI)</h3>
                    <p className="text-xs text-gray-500 mt-1">Metode pembayaran dipilih langsung di web Anda (VA, QRIS, E-Wallet). Butuh konfigurasi Core API.</p>
                </div>
                {mode === 'CORE' && <div className="w-3 h-3 rounded-full bg-black ml-auto"></div>}
            </div>
        </div>
        <div className="mt-4 flex justify-end">
            <button onClick={handleSaveMode} className="bg-black text-white px-4 py-2 rounded-lg font-bold text-sm flex items-center gap-2 hover:bg-gray-800">
                <Save size={16} /> Simpan Mode
            </button>
        </div>
      </div>

      {/* PAYMENT METHODS LIST (Only relevant if CORE mode, but allow editing always) */}
      <div className={`bg-white p-6 rounded-xl border border-gray-200 shadow-sm transition-opacity ${mode !== 'CORE' ? 'opacity-50 pointer-events-none' : ''}`}>
        <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-bold flex items-center gap-2">
                <CreditCard size={20} /> Daftar Metode Pembayaran (Core API)
            </h2>
            {mode !== 'CORE' && <span className="text-xs bg-gray-100 px-2 py-1 rounded">Aktifkan Mode 'Core API' untuk mengelola ini</span>}
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 border-b border-gray-100 text-gray-500">
              <tr>
                <th className="p-4 font-bold">Metode</th>
                <th className="p-4 font-bold">Kode</th>
                <th className="p-4 font-bold">Tipe</th>
                <th className="p-4 font-bold text-center">Status</th>
                <th className="p-4 font-bold text-center">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {methods.map((m) => (
                <tr key={m.id} className="hover:bg-gray-50">
                  <td className="p-4 font-bold">{m.name}</td>
                  <td className="p-4 font-mono text-gray-500">{m.code}</td>
                  <td className="p-4"><span className="bg-gray-100 px-2 py-1 rounded text-xs font-bold">{m.type}</span></td>
                  <td className="p-4 text-center">
                    <span className={`px-2 py-1 rounded-full text-xs font-bold ${m.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                      {m.isActive ? 'Aktif' : 'Nonaktif'}
                    </span>
                  </td>
                  <td className="p-4 text-center">
                    <button 
                        onClick={() => handleToggleMethod(m.id)}
                        className={`px-3 py-1 rounded border text-xs font-bold ${m.isActive ? 'border-red-200 text-red-600 hover:bg-red-50' : 'border-green-200 text-green-600 hover:bg-green-50'}`}
                    >
                        {m.isActive ? 'Matikan' : 'Aktifkan'}
                    </button>
                  </td>
                </tr>
              ))}
              {methods.length === 0 && (
                  <tr>
                      <td colSpan={5} className="p-8 text-center text-gray-500">
                          Belum ada data metode pembayaran. Jalankan seeding di server.
                      </td>
                  </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}