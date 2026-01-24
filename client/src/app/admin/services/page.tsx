'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import axios from 'axios';
import { Plus, Edit, Trash2, Globe, Laptop, Code, Database, Search } from 'lucide-react';
import toast from 'react-hot-toast';

export default function AdminServicesPage() {
  const { token } = useAuthStore();
  const [services, setServices] = useState<any[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ title: '', description: '', price: '', icon: 'Code' });

  useEffect(() => { fetchServices(); }, []);

  const fetchServices = async () => {
    try {
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/services`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setServices(res.data);
    } catch (err) { console.error(err); }
  };

  const handleSave = async () => {
    try {
      await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/admin/services`, form, {
        headers: { Authorization: `Bearer ${token}` }
      });
      toast.success('Layanan disimpan');
      setShowModal(false);
      fetchServices();
    } catch (err) { toast.error('Gagal menyimpan'); }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <main className="max-w-6xl mx-auto px-8 py-24">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold">Kelola Jasa & Layanan</h1>
          <button onClick={() => setShowModal(true)} className="bg-black text-white px-4 py-2 rounded-lg flex items-center gap-2"><Plus size={18}/> Tambah Jasa</button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {services.map(s => (
            <div key={s.id} className="bg-white p-6 rounded-xl border border-gray-200 flex justify-between items-center">
              <div>
                <h3 className="font-bold">{s.title}</h3>
                <p className="text-sm text-gray-400">{s.price}</p>
              </div>
              <div className="flex gap-2">
                <button className="p-2 hover:bg-gray-100 rounded-lg text-blue-600"><Edit size={18}/></button>
                <button className="p-2 hover:bg-gray-100 rounded-lg text-red-600"><Trash2 size={18}/></button>
              </div>
            </div>
          ))}
        </div>

        {showModal && (
          <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[100]">
            <div className="bg-white p-8 rounded-2xl w-full max-w-md shadow-2xl">
              <h2 className="text-xl font-bold mb-6">Tambah/Edit Layanan</h2>
              <div className="space-y-4">
                <input value={form.title} onChange={e => setForm({...form, title: e.target.value})} className="w-full p-3 border rounded-lg" placeholder="Nama Jasa" />
                <textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="w-full p-3 border rounded-lg" placeholder="Deskripsi Singkat" />
                <input value={form.price} onChange={e => setForm({...form, price: e.target.value})} className="w-full p-3 border rounded-lg" placeholder="Harga (Misal: Mulai Rp 1jt)" />
                <select value={form.icon} onChange={e => setForm({...form, icon: e.target.value})} className="w-full p-3 border rounded-lg">
                  <option value="Globe">Globe</option>
                  <option value="Code">Code</option>
                  <option value="Laptop">Laptop</option>
                  <option value="Database">Database</option>
                </select>
              </div>
              <div className="flex justify-end gap-3 mt-8">
                <button onClick={() => setShowModal(false)} className="px-4 py-2">Batal</button>
                <button onClick={handleSave} className="bg-black text-white px-6 py-2 rounded-lg font-bold">Simpan Layanan</button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
