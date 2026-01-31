'use client';

import { useState, useEffect } from 'react';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Plus, Trash2, Ticket, Calendar } from 'lucide-react';
import { useRouter } from 'next/navigation';

interface Voucher {
  id: string;
  code: string;
  type: 'PERCENT' | 'FIXED';
  value: number;
  minPurchase: number;
  usageLimit: number;
  usedCount: number;
  expiresAt: string;
}

export default function VoucherPage() {
  const [vouchers, setVouchers] = useState<Voucher[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  
  // Form State
  const [formData, setFormData] = useState({
    code: '',
    type: 'FIXED',
    value: 0,
    minPurchase: 0,
    usageLimit: 0,
    expiresAt: ''
  });

  const fetchVouchers = async () => {
    try {
      const res = await api.get('/vouchers');
      setVouchers(res.data);
    } catch (error) {
      toast.error('Gagal mengambil data voucher');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVouchers();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/vouchers', formData);
      toast.success('Voucher berhasil dibuat');
      setShowModal(false);
      fetchVouchers();
      setFormData({ code: '', type: 'FIXED', value: 0, minPurchase: 0, usageLimit: 0, expiresAt: '' });
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Gagal membuat voucher');
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Yakin hapus voucher ini?')) return;
    try {
      await api.delete(`/vouchers/${id}`);
      toast.success('Voucher dihapus');
      fetchVouchers();
    } catch (error) {
      toast.error('Gagal menghapus');
    }
  };

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <Ticket className="text-accent" /> Manajemen Voucher
        </h1>
        <button 
          onClick={() => setShowModal(true)}
          className="bg-black text-white px-6 py-2.5 rounded-xl font-bold flex items-center gap-2 hover:bg-gray-800"
        >
          <Plus size={18} /> Buat Voucher
        </button>
      </div>

      <div className="bg-white rounded-3xl border border-gray-100 shadow-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
            <tr>
              <th className="text-left p-6 font-bold text-sm text-gray-500">KODE</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">TIPE</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">NILAI</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">MIN BELANJA</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">USAGE</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">EXPIRED</th>
              <th className="text-right p-6 font-bold text-sm text-gray-500">AKSI</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={7} className="p-8 text-center">Loading...</td></tr>
            ) : vouchers.length === 0 ? (
              <tr><td colSpan={7} className="p-8 text-center text-gray-400">Belum ada voucher</td></tr>
            ) : (
              vouchers.map((v) => (
                <tr key={v.id} className="border-b border-gray-50 hover:bg-gray-50/50 transition-colors">
                  <td className="p-6 font-bold font-mono text-lg">{v.code}</td>
                  <td className="p-6">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${v.type === 'PERCENT' ? 'bg-blue-100 text-blue-600' : 'bg-green-100 text-green-600'}`}>
                      {v.type}
                    </span>
                  </td>
                  <td className="p-6 font-medium">
                    {v.type === 'PERCENT' ? `${v.value}%` : `Rp${v.value.toLocaleString('id-ID')}`}
                  </td>
                  <td className="p-6 text-gray-500">Rp{v.minPurchase.toLocaleString('id-ID')}</td>
                  <td className="p-6 text-gray-500">{v.usedCount} / {v.usageLimit === 0 ? '∞' : v.usageLimit}</td>
                  <td className="p-6 text-gray-500 flex items-center gap-2">
                    <Calendar size={14} />
                    {new Date(v.expiresAt).toLocaleDateString('id-ID')}
                  </td>
                  <td className="p-6 text-right">
                    <button 
                      onClick={() => handleDelete(v.id)}
                      className="p-2 bg-red-50 text-red-500 rounded-lg hover:bg-red-100 transition-colors"
                    >
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* MODAL */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
          <div className="bg-white p-8 rounded-3xl w-full max-w-md shadow-2xl animate-in fade-in zoom-in duration-200">
            <h2 className="text-2xl font-bold mb-6">Buat Voucher Baru</h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="text-sm font-bold ml-1">Kode Voucher (Unik)</label>
                <input 
                  type="text" 
                  className="w-full p-3 border rounded-xl font-mono uppercase mt-1"
                  placeholder="HEMAT100"
                  value={formData.code}
                  onChange={e => setFormData({...formData, code: e.target.value.toUpperCase()})}
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-bold ml-1">Tipe</label>
                  <select 
                    className="w-full p-3 border rounded-xl mt-1 bg-white"
                    value={formData.type}
                    onChange={e => setFormData({...formData, type: e.target.value as any})}
                  >
                    <option value="FIXED">Potongan Harga (Rp)</option>
                    <option value="PERCENT">Persen (%)</option>
                  </select>
                </div>
                <div>
                  <label className="text-sm font-bold ml-1">Nilai</label>
                  <input 
                    type="number" 
                    className="w-full p-3 border rounded-xl mt-1"
                    placeholder="Contoh: 10000 atau 10"
                    value={formData.value}
                    onChange={e => setFormData({...formData, value: Number(e.target.value)})}
                    required
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-bold ml-1">Min. Belanja</label>
                  <input 
                    type="number" 
                    className="w-full p-3 border rounded-xl mt-1"
                    value={formData.minPurchase}
                    onChange={e => setFormData({...formData, minPurchase: Number(e.target.value)})}
                  />
                </div>
                <div>
                  <label className="text-sm font-bold ml-1">Limit Pakai (0=Unl)</label>
                  <input 
                    type="number" 
                    className="w-full p-3 border rounded-xl mt-1"
                    value={formData.usageLimit}
                    onChange={e => setFormData({...formData, usageLimit: Number(e.target.value)})}
                  />
                </div>
              </div>
              <div>
                <label className="text-sm font-bold ml-1">Kadaluarsa Pada</label>
                <input 
                  type="date" 
                  className="w-full p-3 border rounded-xl mt-1"
                  value={formData.expiresAt}
                  onChange={e => setFormData({...formData, expiresAt: e.target.value})}
                  required
                />
              </div>

              <div className="flex gap-3 mt-6">
                <button 
                  type="button" 
                  onClick={() => setShowModal(false)}
                  className="flex-1 py-3 border border-gray-200 rounded-xl font-bold hover:bg-gray-50"
                >
                  Batal
                </button>
                <button 
                  type="submit" 
                  className="flex-1 py-3 bg-black text-white rounded-xl font-bold hover:bg-gray-800"
                >
                  Simpan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
