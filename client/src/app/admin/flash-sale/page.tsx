'use client';

import { useState, useEffect } from 'react';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Plus, Trash2, Zap, Calendar } from 'lucide-react';

interface FlashSale {
  id: string;
  productId: string;
  discountPrice: number;
  startTime: string;
  endTime: string;
  product: { name: string; price: number };
}

interface Product {
  id: string;
  name: string;
  price: number;
}

export default function FlashSalePage() {
  const [flashSales, setFlashSales] = useState<FlashSale[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  
  const [formData, setFormData] = useState({
    productId: '',
    discountPrice: 0,
    startTime: '',
    endTime: ''
  });

  const fetchData = async () => {
    try {
      const [fsRes, pRes] = await Promise.all([
        api.get('/flash-sales'),
        api.get('/products')
      ]);
      setFlashSales(fsRes.data);
      setProducts(pRes.data);
    } catch (error) {
      toast.error('Gagal mengambil data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/flash-sales', formData);
      toast.success('Flash Sale dibuat');
      setShowModal(false);
      fetchData();
    } catch (error: any) {
      toast.error('Gagal membuat');
    }
  };

  const handleDelete = (id: string) => {
    toast((t) => (
      <div className="flex flex-col gap-3 min-w-[240px]">
        <span className="font-bold text-sm text-center">Hapus Flash Sale ini?</span>
        <div className="flex gap-2 justify-center">
          <button onClick={() => toast.dismiss(t.id)} className="px-4 py-2 bg-gray-50 hover:bg-gray-100 rounded-xl text-xs font-bold transition-colors">Batal</button>
          <button 
            onClick={async () => {
              toast.dismiss(t.id);
              try {
                await api.delete(`/flash-sales/${id}`);
                fetchData();
                toast.success('Berhasil dihapus');
              } catch (error) { toast.error('Gagal menghapus'); }
            }} 
            className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-xl text-xs font-bold transition-colors shadow-lg shadow-red-200"
          >
            Hapus
          </button>
        </div>
      </div>
    ));
  };

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <Zap className="text-yellow-500 fill-yellow-500" /> Flash Sale
        </h1>
        <button 
          onClick={() => setShowModal(true)}
          className="bg-black text-white px-6 py-2.5 rounded-xl font-bold flex items-center gap-2 hover:bg-gray-800"
        >
          <Plus size={18} /> Buat Flash Sale
        </button>
      </div>

      <div className="grid gap-4">
        {flashSales.map(fs => (
          <div key={fs.id} className="bg-white p-6 rounded-2xl border flex justify-between items-center shadow-sm">
            <div>
              <h3 className="font-bold text-lg">{fs.product.name}</h3>
              <div className="flex gap-4 mt-2 text-sm text-gray-500">
                <p>Normal: <span className="line-through">Rp{fs.product.price.toLocaleString()}</span></p>
                <p className="text-red-500 font-bold">Promo: Rp{fs.discountPrice.toLocaleString()}</p>
              </div>
              <div className="flex gap-4 mt-1 text-xs text-gray-400">
                <p>Mulai: {new Date(fs.startTime).toLocaleString()}</p>
                <p>Selesai: {new Date(fs.endTime).toLocaleString()}</p>
              </div>
            </div>
            <button onClick={() => handleDelete(fs.id)} className="text-red-500 bg-red-50 p-3 rounded-xl hover:bg-red-100">
              <Trash2 size={20} />
            </button>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white p-8 rounded-3xl w-full max-w-md">
            <h2 className="text-2xl font-bold mb-6">Set Flash Sale</h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="text-sm font-bold">Pilih Produk</label>
                <select 
                  className="w-full p-3 border rounded-xl mt-1 bg-white"
                  onChange={e => setFormData({...formData, productId: e.target.value})}
                >
                  <option value="">-- Pilih --</option>
                  {products.map(p => (
                    <option key={p.id} value={p.id}>{p.name} - Rp{p.price.toLocaleString()}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-sm font-bold">Harga Diskon</label>
                <input 
                  type="number" 
                  className="w-full p-3 border rounded-xl mt-1"
                  onChange={e => setFormData({...formData, discountPrice: Number(e.target.value)})}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-bold">Mulai</label>
                  <input 
                    type="datetime-local" 
                    className="w-full p-3 border rounded-xl mt-1"
                    onChange={e => setFormData({...formData, startTime: e.target.value})}
                  />
                </div>
                <div>
                  <label className="text-sm font-bold">Selesai</label>
                  <input 
                    type="datetime-local" 
                    className="w-full p-3 border rounded-xl mt-1"
                    onChange={e => setFormData({...formData, endTime: e.target.value})}
                  />
                </div>
              </div>
              <div className="flex gap-3 mt-6">
                <button type="button" onClick={() => setShowModal(false)} className="flex-1 py-3 border rounded-xl">Batal</button>
                <button type="submit" className="flex-1 py-3 bg-black text-white rounded-xl">Simpan</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
