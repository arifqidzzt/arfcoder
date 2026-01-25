'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import Link from 'next/link';
import { Plus, Edit, Trash2, Search, ArrowLeft } from 'lucide-react';
import api from '@/lib/api';
import toast from 'react-hot-toast';

interface Product {
  id: string;
  name: string;
  price: number;
  stock: number;
  category: { name: string } | null;
  type: string;
}

export default function AdminProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const { user, token } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      router.push('/login');
      return;
    }
    fetchProducts();
  }, [user]);

  const fetchProducts = async () => {
    try {
      const res = await api.get('/products');
      setProducts(res.data);
    } catch (error) {
      toast.error('Gagal memuat produk');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = (id: string) => {
    toast((t) => (
      <div className="flex flex-col gap-2 min-w-[200px]">
        <span className="font-bold text-sm">Hapus produk ini?</span>
        <div className="flex gap-2 justify-end mt-2">
          <button onClick={() => toast.dismiss(t.id)} className="px-3 py-1.5 bg-gray-100 rounded-lg text-xs font-bold">Batal</button>
          <button onClick={() => confirmDelete(id, t.id)} className="px-3 py-1.5 bg-red-600 text-white rounded-lg text-xs font-bold">Hapus</button>
        </div>
      </div>
    ), { position: 'top-center' });
  };

  const confirmDelete = async (id: string, toastId: string) => {
    toast.dismiss(toastId);
    try {
      await api.delete(`/products/${id}`);
      toast.success('Produk dihapus');
      fetchProducts();
    } catch (error) { toast.error('Gagal menghapus'); }
  };

  const filteredProducts = products.filter(p => 
    p.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
             <Link href="/admin" className="p-2 hover:bg-gray-200 rounded-full transition-colors">
               <ArrowLeft size={20} />
             </Link>
             <div>
                <h1 className="text-2xl font-bold">Manajemen Produk</h1>
                <p className="text-gray-500">Kelola katalog produk dan jasa Anda.</p>
             </div>
          </div>
          <Link href="/admin/products/new" className="bg-black text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 hover:bg-gray-800 transition-colors">
            <Plus size={18} />
            Tambah Produk
          </Link>
        </div>

        <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
          {/* Toolbar */}
          <div className="p-4 border-b border-gray-100 flex gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
              <input 
                type="text" 
                placeholder="Cari nama produk..." 
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-black"
              />
            </div>
          </div>

          {/* Table */}
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-4 font-semibold text-gray-600">Nama Produk</th>
                  <th className="px-6 py-4 font-semibold text-gray-600">Kategori</th>
                  <th className="px-6 py-4 font-semibold text-gray-600">Tipe</th>
                  <th className="px-6 py-4 font-semibold text-gray-600">Harga</th>
                  <th className="px-6 py-4 font-semibold text-gray-600">Stok</th>
                  <th className="px-6 py-4 font-semibold text-gray-600 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {loading ? (
                  <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-400">Memuat data...</td></tr>
                ) : filteredProducts.length === 0 ? (
                  <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-400">Tidak ada produk ditemukan.</td></tr>
                ) : (
                  filteredProducts.map((product) => (
                    <tr key={product.id} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 font-medium">{product.name}</td>
                      <td className="px-6 py-4 text-gray-500">{product.category?.name || '-'}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 rounded text-xs font-bold ${product.type === 'JASA' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}`}>
                          {product.type}
                        </span>
                      </td>
                      <td className="px-6 py-4">Rp {product.price.toLocaleString('id-ID')}</td>
                      <td className="px-6 py-4">{product.stock}</td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex justify-end gap-2">
                          <Link href={`/admin/products/${product.id}`} className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                            <Edit size={18} />
                          </Link>
                          <button 
                            onClick={() => handleDelete(product.id)}
                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                          >
                            <Trash2 size={18} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
