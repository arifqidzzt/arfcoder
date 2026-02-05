'use client';

import { useState, useEffect } from 'react';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Settings, Save, CreditCard, ShieldCheck } from 'lucide-react';

const AVAILABLE_METHODS = [
  { id: 'bca', name: 'BCA Virtual Account', type: 'VA' },
  { id: 'bni', name: 'BNI Virtual Account', type: 'VA' },
  { id: 'bri', name: 'BRI Virtual Account', type: 'VA' },
  { id: 'permata', name: 'Permata Virtual Account', type: 'VA' },
  { id: 'mandiri', name: 'Mandiri Bill Payment', type: 'VA' },
  { id: 'qris', name: 'QRIS', type: 'E-Wallet' },
  { id: 'gopay', name: 'GoPay', type: 'E-Wallet' },
  { id: 'shopeepay', name: 'ShopeePay', type: 'E-Wallet' },
];

export default function AdminSettingsPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [paymentMode, setPaymentMode] = useState('snap');
  const [selectedMethods, setSelectedMethods] = useState<string[]>([]);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const res = await api.get('/settings');
      setPaymentMode(res.data.paymentMode || 'snap');
      setSelectedMethods(res.data.defaultPaymentMethods || []);
    } catch (error) {
      toast.error('Gagal mengambil pengaturan');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleMethod = (id: string) => {
    setSelectedMethods(prev => 
      prev.includes(id) ? prev.filter(m => m !== id) : [...prev, id]
    );
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await api.put('/settings', {
        paymentMode,
        defaultPaymentMethods: selectedMethods
      });
      toast.success('Pengaturan berhasil disimpan');
    } catch (error) {
      toast.error('Gagal menyimpan pengaturan');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div className="p-8 text-center">Loading settings...</div>;

  return (
    <div className="p-4 sm:p-8 max-w-4xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold flex items-center gap-2">
          <Settings className="text-accent" /> Pengaturan Pembayaran
        </h1>
        <button 
          onClick={handleSave}
          disabled={saving}
          className="bg-black text-white px-6 py-2.5 rounded-xl font-bold flex items-center gap-2 hover:bg-gray-800 disabled:bg-gray-400"
        >
          {saving ? 'Menyimpan...' : <><Save size={18} /> Simpan Perubahan</>}
        </button>
      </div>

      <div className="space-y-6">
        {/* Mode Pembayaran */}
        <div className="bg-white p-8 rounded-3xl border border-gray-100 shadow-sm">
          <h2 className="text-xl font-bold mb-4">Mode Pembayaran Global</h2>
          <p className="text-gray-500 text-sm mb-6">Pilih bagaimana sistem menangani transaksi Midtrans secara default.</p>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <button 
              onClick={() => setPaymentMode('snap')}
              className={`p-6 rounded-2xl border-2 text-left transition-all ${paymentMode === 'snap' ? 'border-black bg-gray-50' : 'border-gray-100 hover:border-gray-200'}`}
            >
              <div className="flex justify-between items-start mb-2">
                <div className="p-2 bg-blue-100 text-blue-600 rounded-lg"><ShieldCheck size={20} /></div>
                {paymentMode === 'snap' && <div className="w-4 h-4 bg-black rounded-full" />}
              </div>
              <h3 className="font-bold">Midtrans Snap</h3>
              <p className="text-xs text-gray-400 mt-1">Gunakan pop-up/redirect standar Midtrans. Mudah digunakan tapi kurang terintegrasi secara visual.</p>
            </button>

            <button 
              onClick={() => setPaymentMode('core_api')}
              className={`p-6 rounded-2xl border-2 text-left transition-all ${paymentMode === 'core_api' ? 'border-black bg-gray-50' : 'border-gray-100 hover:border-gray-200'}`}
            >
              <div className="flex justify-between items-start mb-2">
                <div className="p-2 bg-purple-100 text-purple-600 rounded-lg"><CreditCard size={20} /></div>
                {paymentMode === 'core_api' && <div className="w-4 h-4 bg-black rounded-full" />}
              </div>
              <h3 className="font-bold">Midtrans Core API</h3>
              <p className="text-xs text-gray-400 mt-1">Kontrol penuh UI pembayaran. Metode pembayaran dipilih langsung di website Anda.</p>
            </button>
          </div>
        </div>

        {/* Metode Pembayaran (Hanya jika Core API) */}
        {paymentMode === 'core_api' && (
          <div className="bg-white p-8 rounded-3xl border border-gray-100 shadow-sm animate-in fade-in slide-in-from-top-4 duration-300">
            <h2 className="text-xl font-bold mb-4">Metode Pembayaran Aktif</h2>
            <p className="text-gray-500 text-sm mb-6">Pilih metode pembayaran yang ingin Anda aktifkan saat menggunakan Core API.</p>
            
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {AVAILABLE_METHODS.map(method => (
                <div 
                  key={method.id}
                  onClick={() => handleToggleMethod(method.id)}
                  className={`p-4 rounded-xl border flex items-center justify-between cursor-pointer transition-all ${selectedMethods.includes(method.id) ? 'border-black bg-gray-50' : 'border-gray-100 hover:bg-gray-50'}`}
                >
                  <div>
                    <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest block">{method.type}</span>
                    <span className="font-bold">{method.name}</span>
                  </div>
                  <div className={`w-5 h-5 rounded border-2 flex items-center justify-center ${selectedMethods.includes(method.id) ? 'bg-black border-black' : 'border-gray-200'}`}>
                    {selectedMethods.includes(method.id) && <div className="w-2 h-2 bg-white rounded-full" />}
                  </div>
                </div>
              ))}
            </div>
            {selectedMethods.length === 0 && (
              <div className="mt-4 p-4 bg-yellow-50 text-yellow-700 rounded-xl text-xs flex items-center gap-2">
                ⚠️ Jika tidak ada metode yang dipilih, sistem akan menampilkan semua metode default.
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
