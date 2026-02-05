'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import api from '@/lib/api';
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
    images: initialData?.images?.[0] || '', 
    useCoreApi: initialData?.useCoreApi || false,
    paymentMethods: initialData?.paymentMethods || [],
  });

  const AVAILABLE_METHODS = [
    { id: 'bca', name: 'BCA VA' },
    { id: 'bni', name: 'BNI VA' },
    { id: 'bri', name: 'BRI VA' },
    { id: 'permata', name: 'Permata VA' },
    { id: 'mandiri', name: 'Mandiri Bill' },
    { id: 'qris', name: 'QRIS' },
    { id: 'gopay', name: 'GoPay' },
    { id: 'shopeepay', name: 'ShopeePay' },
  ];

  const handleToggleMethod = (id: string) => {
    setFormData(prev => ({
      ...prev,
      paymentMethods: prev.paymentMethods.includes(id)
        ? prev.paymentMethods.filter((m: string) => m !== id)
        : [...prev.paymentMethods, id]
    }));
  };

  const handleChange = (e: any) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : (name === 'price' || name === 'stock' || name === 'discount' ? parseFloat(value) : value)
    }));
  };

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({ ...prev, images: reader.result as string }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const payload = {
      ...formData,
      images: [formData.images], 
    };

    try {
      if (isEdit) {
        await api.put(`/products/${initialData.id}`, payload);
        toast.success('Produk berhasil diperbarui');
      } else {
        await api.post('/products', payload);
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
            <label className="block text-sm font-bold mb-2">Gambar Produk</label>
            
            {formData.images && (
              <img src={formData.images} alt="Preview" className="w-32 h-32 object-cover rounded-lg mb-4 border border-gray-200" />
            )}
            
            <div className="flex gap-4">
              <input 
                type="text"
                name="images"
                value={formData.images}
                onChange={handleChange}
                placeholder="URL Gambar (Opsional)"
                className="flex-1 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
              />
              <div className="relative">
                <input 
                  type="file" 
                  onChange={handleImageUpload}
                  className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                  accept="image/*"
                />
                <button type="button" className="px-4 py-2 bg-gray-100 rounded-lg font-bold text-sm hover:bg-gray-200">
                  Upload File
                </button>
              </div>
            </div>
            <p className="text-xs text-gray-400 mt-1">Paste URL atau Upload dari perangkat.</p>
          </div>

          {/* Payment Configuration */}
          <div className="md:col-span-2 pt-6 border-t border-gray-100">
            <h3 className="text-lg font-bold mb-4">Pengaturan Pembayaran</h3>
            <div className="flex items-center gap-3 mb-6 p-4 bg-gray-50 rounded-2xl">
              <input 
                type="checkbox"
                name="useCoreApi"
                id="useCoreApi"
                checked={formData.useCoreApi}
                onChange={handleChange}
                className="w-5 h-5 rounded border-gray-300 accent-black"
              />
              <label htmlFor="useCoreApi" className="font-bold cursor-pointer">Gunakan Midtrans Core API untuk produk ini</label>
            </div>

            {formData.useCoreApi && (
              <div className="animate-in fade-in slide-in-from-top-2 duration-300">
                <label className="block text-sm font-bold mb-3">Metode Pembayaran Khusus (Opsional)</label>
                <p className="text-xs text-gray-500 mb-4">Jika dikosongkan, akan menggunakan pengaturan default admin.</p>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                  {AVAILABLE_METHODS.map(method => (
                    <div 
                      key={method.id}
                      onClick={() => handleToggleMethod(method.id)}
                      className={`p-3 rounded-xl border text-center cursor-pointer transition-all text-sm font-medium ${formData.paymentMethods.includes(method.id) ? 'border-black bg-black text-white' : 'border-gray-200 bg-white hover:border-gray-300'}`}
                    >
                      {method.name}
                    </div>
                  ))}
                </div>
              </div>
            )}
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