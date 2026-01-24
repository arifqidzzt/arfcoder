'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import axios from 'axios';
import toast from 'react-hot-toast';
import { ArrowLeft, Save } from 'lucide-react';
import Link from 'next/link';

interface ProductFormProps {
  initialData?: any;
  isEdit?: boolean;
}

export default function ProductForm({ initialData, isEdit = false }: ProductFormProps) {
  const router = useRouter();
  const { token } = useAuthStore();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: initialData?.name || '',
    description: initialData?.description || '',
    price: initialData?.price || 0,
    stock: initialData?.stock || 0,
    type: initialData?.type || 'BARANG',
    discount: initialData?.discount || 0,
    images: initialData?.images?.[0] || '', // Simple single image input for now
  });

  const handleChange = (e: any) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'price' || name === 'stock' || name === 'discount' ? parseFloat(value) : value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const payload = {
      ...formData,
      images: [formData.images], // Convert back to array
    };

    try {
      if (isEdit) {
        await axios.put(`${process.env.NEXT_PUBLIC_API_URL}/products/${initialData.id}`, payload, {
          headers: { Authorization: `Bearer ${token}` }
        });
        toast.success('Produk berhasil diperbarui');
      } else {
        await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/products`, payload, {
          headers: { Authorization: `Bearer ${token}` }
        });
        toast.success('Produk berhasil ditambahkan');
      }
      router.push('/admin/products');
    } catch (error) {
      toast.error('Gagal menyimpan produk');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto">
      <form onSubmit={handleSubmit} className="bg-white rounded-xl border border-gray-200 shadow-sm p-8 space-y-6">
        
        {/* Basic Info */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="md:col-span-2">
            <label className="block text-sm font-bold mb-2">Nama Produk</label>
            <input 
              name="name"
              value={formData.name}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
              required
            />
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-bold mb-2">Deskripsi</label>
            <textarea 
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows={4}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-bold mb-2">Harga (Rp)</label>
            <input 
              type="number"
              name="price"
              value={formData.price}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-bold mb-2">Diskon (%)</label>
            <input 
              type="number"
              name="discount"
              value={formData.discount}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
            />
          </div>

          <div>
            <label className="block text-sm font-bold mb-2">Stok</label>
            <input 
              type="number"
              name="stock"
              value={formData.stock}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-bold mb-2">Tipe Produk</label>
            <select 
              name="type"
              value={formData.type}
              onChange={handleChange}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
            >
              <option value="BARANG">Barang Fisik / Digital</option>
              <option value="JASA">Jasa / Layanan</option>
            </select>
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-bold mb-2">URL Gambar</label>
            <input 
              name="images"
              value={formData.images}
              onChange={handleChange}
              placeholder="https://example.com/image.jpg"
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
            />
            <p className="text-xs text-gray-400 mt-1">Masukkan URL gambar langsung (contoh dari Unsplash atau Placehold.co).</p>
          </div>
        </div>

        <div className="pt-6 border-t border-gray-100 flex justify-end gap-4">
          <Link href="/admin/products" className="px-6 py-3 text-gray-600 font-medium hover:bg-gray-100 rounded-lg transition-colors">
            Batal
          </Link>
          <button 
            type="submit" 
            disabled={loading}
            className="px-6 py-3 bg-black text-white font-medium rounded-lg hover:bg-gray-800 transition-colors flex items-center gap-2"
          >
            <Save size={18} />
            {loading ? 'Menyimpan...' : 'Simpan Produk'}
          </button>
        </div>
      </form>
    </div>
  );
}
