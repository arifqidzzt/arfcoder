'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import { useCartStore } from '@/store/useCartStore';
import { ShoppingCart, Search, Filter, SlidersHorizontal, ArrowUpDown } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '@/lib/api';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  discount: number;
  images: string[];
  type: string;
  category?: { name: string };
}

export default function ProductList() {
  const [products, setProducts] = useState<Product[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedType, setSelectedType] = useState('ALL'); // ALL, BARANG, JASA
  const [sortBy, setSortBy] = useState('newest'); // newest, price_low, price_high
  const addItem = useCartStore((state) => state.addItem);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const res = await api.get(`/products`);
        setProducts(res.data);
        setFilteredProducts(res.data);
      } catch (error) {
        console.error('Failed to fetch products');
      } finally {
        setLoading(false);
      }
    };
    fetchProducts();
  }, []);

  // Filter & Sort Logic
  useEffect(() => {
    let result = [...products];

    // 1. Search
    if (search) {
      result = result.filter(p => 
        p.name.toLowerCase().includes(search.toLowerCase()) || 
        p.description.toLowerCase().includes(search.toLowerCase())
      );
    }

    // 2. Type Filter
    if (selectedType !== 'ALL') {
      result = result.filter(p => p.type === selectedType);
    }

    // 3. Sorting
    if (sortBy === 'price_low') {
      result.sort((a, b) => (a.price * (1 - a.discount/100)) - (b.price * (1 - b.discount/100)));
    } else if (sortBy === 'price_high') {
      result.sort((a, b) => (b.price * (1 - b.discount/100)) - (a.price * (1 - a.discount/100)));
    }
    // 'newest' is default from API (usually)

    setFilteredProducts(result);
  }, [search, selectedType, sortBy, products]);

  const handleAddToCart = (e: React.MouseEvent, product: Product) => {
    e.preventDefault();
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - product.discount / 100),
      quantity: 1,
      image: product.images[0] || 'https://placehold.co/600x400/000000/FFFFFF?text=No+Image',
    });
    toast.success(`${product.name} +1`);
  };

  return (
    <div className="min-h-screen bg-gray-50/50">
      <Navbar />
      
      <main className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-24">
        {/* Header Section */}
        <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-6">
          <div>
            <h1 className="text-4xl font-black tracking-tight mb-2 text-gray-900">Katalog Produk</h1>
            <p className="text-gray-500 font-medium">Koleksi terbaik untuk kebutuhan digital Anda.</p>
          </div>
          
          <div className="flex flex-col sm:flex-row gap-4 w-full md:w-auto">
            <div className="relative group">
              <Search className="absolute left-4 top-3.5 text-gray-400 group-focus-within:text-black transition-colors" size={18} />
              <input 
                type="text" 
                placeholder="Cari produk..." 
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full sm:w-80 pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-black/5 focus:border-black transition-all shadow-sm"
              />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-10">
          {/* Sidebar Filter */}
          <aside className="lg:col-span-1 space-y-8">
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm sticky top-24">
              <div className="flex items-center gap-2 mb-6 text-gray-900">
                <Filter size={20} />
                <h3 className="font-bold text-lg">Filter</h3>
              </div>

              {/* Kategori */}
              <div className="mb-8">
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Tipe Produk</h4>
                <div className="space-y-2">
                  {['ALL', 'BARANG', 'JASA'].map((type) => (
                    <button
                      key={type}
                      onClick={() => setSelectedType(type)}
                      className={`w-full text-left px-4 py-2.5 rounded-lg text-sm font-medium transition-all
                        ${selectedType === type 
                          ? 'bg-black text-white shadow-md' 
                          : 'text-gray-600 hover:bg-gray-50 hover:text-black'}`}
                    >
                      {type === 'ALL' ? 'Semua Produk' : type === 'BARANG' ? 'Produk Digital' : 'Jasa & Layanan'}
                    </button>
                  ))}
                </div>
              </div>

              {/* Sorting */}
              <div>
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Urutkan</h4>
                <div className="relative">
                  <select 
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value)}
                    className="w-full appearance-none bg-gray-50 border border-gray-200 text-gray-700 py-3 px-4 pr-8 rounded-xl leading-tight focus:outline-none focus:bg-white focus:border-black text-sm font-medium"
                  >
                    <option value="newest">Terbaru</option>
                    <option value="price_low">Harga Terendah</option>
                    <option value="price_high">Harga Tertinggi</option>
                  </select>
                  <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-gray-500">
                    <ArrowUpDown size={14} />
                  </div>
                </div>
              </div>
            </div>
          </aside>

          {/* Product Grid */}
          <div className="lg:col-span-3">
            {loading ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {[1, 2, 3, 4, 5, 6].map((n) => (
                  <div key={n} className="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm animate-pulse">
                    <div className="aspect-[4/3] bg-gray-200 rounded-xl mb-4"></div>
                    <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                    <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                  </div>
                ))}
              </div>
            ) : filteredProducts.length === 0 ? (
              <div className="text-center py-32 bg-white rounded-3xl border border-dashed border-gray-200">
                <div className="inline-flex p-4 bg-gray-50 rounded-full mb-4">
                  <Search className="text-gray-400" size={32} />
                </div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">Tidak ada produk ditemukan</h3>
                <p className="text-gray-500">Coba ubah kata kunci atau filter Anda.</p>
                <button 
                  onClick={() => { setSearch(''); setSelectedType('ALL'); }}
                  className="mt-6 text-sm font-bold text-black underline hover:text-gray-600"
                >
                  Reset Filter
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                {filteredProducts.map((product) => (
                  <Link href={`/products/${product.id}`} key={product.id} className="group relative bg-white rounded-3xl border border-gray-100 hover:border-gray-200 overflow-hidden hover:shadow-[0_8px_30px_rgb(0,0,0,0.04)] transition-all duration-300 flex flex-col">
                    {/* Image Container */}
                    <div className="aspect-[4/3] bg-gray-100 overflow-hidden relative">
                      <img 
                        src={product.images[0] || 'https://placehold.co/600x400/f3f4f6/cbd5e1?text=No+Image'} 
                        alt={product.name} 
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700 ease-in-out"
                      />
                      
                      {/* Badges */}
                      <div className="absolute top-4 left-4 flex flex-col gap-2">
                        {product.discount > 0 && (
                          <span className="bg-black/90 backdrop-blur-sm text-white text-[10px] px-2.5 py-1 font-bold rounded-lg tracking-wider shadow-lg">
                            -{product.discount}%
                          </span>
                        )}
                        {product.type === 'JASA' && (
                          <span className="bg-white/90 backdrop-blur-sm text-purple-700 border border-purple-100 text-[10px] px-2.5 py-1 font-bold rounded-lg tracking-wider shadow-sm">
                            JASA
                          </span>
                        )}
                      </div>

                      {/* Quick Add Button (Desktop Hover) */}
                      <button 
                        onClick={(e) => handleAddToCart(e, product)}
                        className="absolute bottom-4 right-4 bg-white text-black p-3 rounded-full shadow-xl translate-y-16 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-300 hover:bg-black hover:text-white z-10"
                        title="Tambah ke Keranjang"
                      >
                        <ShoppingCart size={18} strokeWidth={2.5} />
                      </button>
                    </div>

                    {/* Content */}
                    <div className="p-5 flex-1 flex flex-col">
                      <div className="mb-auto">
                        <h3 className="font-bold text-gray-900 text-lg mb-1 line-clamp-1 group-hover:text-blue-600 transition-colors">
                          {product.name}
                        </h3>
                        <p className="text-sm text-gray-500 line-clamp-2 leading-relaxed">
                          {product.description}
                        </p>
                      </div>
                      
                      <div className="mt-6 pt-4 border-t border-gray-50 flex items-center justify-between">
                        <div className="flex flex-col">
                          {product.discount > 0 && (
                            <span className="text-xs text-gray-400 line-through mb-0.5">
                              Rp {product.price.toLocaleString('id-ID')}
                            </span>
                          )}
                          <span className="font-bold text-lg text-gray-900">
                            Rp {(product.price * (1 - product.discount / 100)).toLocaleString('id-ID')}
                          </span>
                        </div>
                        
                        {/* Mobile Add Button (Always Visible on Touch) */}
                        <button 
                          onClick={(e) => handleAddToCart(e, product)}
                          className="lg:hidden p-2 bg-gray-50 text-gray-900 rounded-lg active:scale-95"
                        >
                          <ShoppingCart size={18} />
                        </button>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}