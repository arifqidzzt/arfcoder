'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import { useCartStore } from '@/store/useCartStore';
import { ShoppingCart, Search, Filter, ArrowUpDown } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { useTranslation } from '@/lib/i18n';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  discount: number;
  images: string[];
  type: string;
  paymentMethods?: string[]; // Added for Core API
  category?: { name: string };
}

export default function ProductList() {
  const { t } = useTranslation();
  const [products, setProducts] = useState<Product[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedType, setSelectedType] = useState('ALL'); 
  const [sortBy, setSortBy] = useState('newest'); 
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

  // Filter & Sort Logic (Restored)
  useEffect(() => {
    let result = [...products];

    if (search) {
      result = result.filter(p => 
        p.name.toLowerCase().includes(search.toLowerCase()) || 
        p.description.toLowerCase().includes(search.toLowerCase())
      );
    }

    if (selectedType !== 'ALL') {
      result = result.filter(p => p.type === selectedType);
    }

    if (sortBy === 'price_low') {
      result.sort((a, b) => (a.price * (1 - a.discount/100)) - (b.price * (1 - b.discount/100)));
    } else if (sortBy === 'price_high') {
      result.sort((a, b) => (b.price * (1 - b.discount/100)) - (a.price * (1 - a.discount/100)));
    }

    setFilteredProducts(result);
  }, [search, selectedType, sortBy, products]);

  const handleAddToCart = (e: React.MouseEvent, product: Product) => {
    e.preventDefault();
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - product.discount / 100),
      quantity: 1,
      image: product.images[0] || 'https://placehold.co/600x400',
      paymentMethods: product.paymentMethods // Passing payment methods
    });
    toast.success(`${product.name} +1`);
  };

  return (
    <div className="min-h-screen bg-gray-50/50">
      <Navbar />
      
      <main className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-24">
        {/* Header Section */}
        <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-6">
          <div data-aos="fade-right">
            <h1 className="text-4xl font-black tracking-tight mb-2 text-gray-900">{t('products.title')}</h1>
            <p className="text-gray-500 font-medium">{filteredProducts.length} {t('products.items_found')}</p>
          </div>
          
          <div data-aos="fade-left" className="flex flex-col sm:flex-row gap-4 w-full md:w-auto">
            <div className="relative group">
              <Search className="absolute left-4 top-3.5 text-gray-400 group-focus-within:text-black transition-colors" size={18} />
              <input 
                type="text" 
                placeholder={t('products.search')} 
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
              <div className="flex items-center gap-2 mb-6 text-gray-900 font-bold">
                <Filter size={20} />
                <h3 className="text-lg">Filter</h3>
              </div>

              <div className="mb-8">
                <h4 className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">{t('products.type')}</h4>
                <div className="space-y-2">
                  {[
                    { id: 'ALL', label: t('products.all') },
                    { id: 'BARANG', label: t('products.digital') },
                    { id: 'JASA', label: t('products.service_type') }
                  ].map((type) => (
                    <button
                      key={type.id}
                      onClick={() => setSelectedType(type.id)}
                      className={`w-full text-left px-4 py-2.5 rounded-xl text-sm font-bold transition-all
                        ${selectedType === type.id 
                          ? 'bg-black text-white shadow-lg shadow-black/10' 
                          : 'text-gray-500 hover:bg-gray-50 hover:text-black'}`}
                    >
                      {type.label}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <h4 className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">{t('products.sort')}</h4>
                <div className="relative">
                  <select 
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value)}
                    className="w-full appearance-none bg-gray-50 border border-gray-200 text-gray-700 py-3 px-4 pr-8 rounded-xl focus:border-black text-sm font-bold"
                  >
                    <option value="newest">{t('products.newest')}</option>
                    <option value="price_low">{t('products.price_low')}</option>
                    <option value="price_high">{t('products.price_high')}</option>
                  </select>
                  <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-gray-500">
                    <ArrowUpDown size={14} />
                  </div>
                </div>
              </div>
            </div>
          </aside>

          {/* Product Grid - RESTORED ORIGINAL UI */}
          <div className="lg:col-span-3">
            {loading ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {[1, 2, 3, 4, 5, 6].map((n) => (
                  <div key={n} className="bg-white rounded-3xl p-4 border border-gray-100 animate-pulse h-80"></div>
                ))}
              </div>
            ) : filteredProducts.length === 0 ? (
              <div className="text-center py-32 bg-white rounded-[2.5rem] border border-dashed border-gray-200">
                <div className="inline-flex p-6 bg-gray-50 rounded-full mb-6">
                  <Search className="text-gray-300" size={48} />
                </div>
                <h3 className="text-2xl font-black text-gray-900 mb-2">{t('products.empty')}</h3>
                <button onClick={() => { setSearch(''); setSelectedType('ALL'); }} className="mt-6 font-black text-sm underline">{t('common.back')}</button>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                {filteredProducts.map((product) => (
                  <Link href={`/products/${product.id}`} key={product.id} className="group relative bg-white rounded-[2rem] border border-gray-100 hover:border-accent/20 overflow-hidden hover:shadow-2xl transition-all duration-500 flex flex-col">
                    <div className="aspect-[4/3] bg-gray-100 overflow-hidden relative shadow-inner">
                      <img 
                        src={product.images[0] || 'https://placehold.co/600x400'} 
                        alt="" 
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700 ease-in-out"
                      />
                      
                      <div className="absolute top-4 left-4 flex flex-col gap-2">
                        {product.discount > 0 && <span className="bg-black text-white text-[10px] px-2.5 py-1 font-black rounded-lg shadow-lg">-{product.discount}%</span>}
                        {product.type === 'JASA' && <span className="bg-white/90 text-purple-700 border border-purple-100 text-[10px] px-2.5 py-1 font-black rounded-lg shadow-sm">JASA</span>}
                      </div>

                      {/* QUICK ADD BUTTON RESTORED */}
                      <button 
                        onClick={(e) => handleAddToCart(e, product)}
                        className="absolute bottom-4 right-4 bg-white text-black p-3 rounded-full shadow-xl translate-y-16 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all z-10 hover:bg-black hover:text-white"
                        title="Add to Cart"
                      >
                        <ShoppingCart size={18} strokeWidth={2.5}/>
                      </button>
                    </div>

                    <div className="p-6 flex-1 flex flex-col">
                      <h3 className="font-bold text-gray-900 text-lg mb-2 line-clamp-1 group-hover:text-accent transition-colors">{product.name}</h3>
                      <p className="text-muted-foreground text-sm line-clamp-2 mb-6 leading-relaxed italic">{product.description}</p>
                      
                      <div className="mt-auto pt-4 border-t border-gray-50 flex items-center justify-between">
                        <div className="flex flex-col">
                          {product.discount > 0 && <span className="text-xs text-gray-400 line-through mb-0.5">Rp {product.price.toLocaleString()}</span>}
                          <span className="font-black text-xl text-black">Rp {(product.price * (1 - product.discount / 100)).toLocaleString()}</span>
                        </div>
                        
                        {/* Mobile Add Button */}
                        <button onClick={(e) => handleAddToCart(e, product)} className="lg:hidden p-2 bg-gray-50 text-gray-900 rounded-lg active:scale-95"><ShoppingCart size={18} /></button>
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
