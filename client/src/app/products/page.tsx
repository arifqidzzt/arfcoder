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

  useEffect(() => {
    let result = [...products];
    if (search) {
      result = result.filter(p => p.name.toLowerCase().includes(search.toLowerCase()) || p.description.toLowerCase().includes(search.toLowerCase()));
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
      image: product.images[0],
    });
    toast.success(`${product.name} +1`);
  };

  return (
    <div className="min-h-screen bg-gray-50/50">
      <Navbar />
      <main className="max-w-[1400px] mx-auto px-4 py-24">
        <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-6">
          <div>
            <h1 className="text-4xl font-black tracking-tight mb-2 text-gray-900">{t('products.title')}</h1>
            <p className="text-gray-500 font-medium">{filteredProducts.length} {t('products.items_found')}</p>
          </div>
          <div className="relative group w-full md:w-80">
            <Search className="absolute left-4 top-3.5 text-gray-400" size={18} />
            <input type="text" placeholder={t('products.search')} value={search} onChange={(e) => setSearch(e.target.value)} className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:border-black transition-all shadow-sm" />
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-10">
          <aside className="lg:col-span-1 space-y-8">
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm sticky top-24">
              <div className="mb-8">
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Type</h4>
                <div className="space-y-2">
                  {['ALL', 'BARANG', 'JASA'].map((type) => (
                    <button key={type} onClick={() => setSelectedType(type)} className={`w-full text-left px-4 py-2.5 rounded-lg text-sm font-medium transition-all ${selectedType === type ? 'bg-black text-white' : 'text-gray-600 hover:bg-gray-50'}`}>
                      {type === 'ALL' ? 'All' : type === 'BARANG' ? 'Digital Products' : 'Services'}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Sort By</h4>
                <select value={sortBy} onChange={(e) => setSortBy(e.target.value)} className="w-full bg-gray-50 border p-3 rounded-xl text-sm font-medium">
                  <option value="newest">Newest</option>
                  <option value="price_low">Price: Low to High</option>
                  <option value="price_high">Price: High to Low</option>
                </select>
              </div>
            </div>
          </aside>

          <div className="lg:col-span-3">
            {loading ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {[1, 2, 3].map((n) => <div key={n} className="bg-white rounded-2xl h-64 animate-pulse"></div>)}
              </div>
            ) : filteredProducts.length === 0 ? (
              <div className="text-center py-32 bg-white rounded-3xl border border-dashed">
                <h3 className="text-xl font-bold mb-2">{t('products.empty')}</h3>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                {filteredProducts.map((product) => (
                  <Link href={`/products/${product.id}`} key={product.id} className="group bg-white rounded-3xl border border-gray-100 overflow-hidden hover:shadow-xl transition-all">
                    <div className="aspect-[4/3] bg-gray-100 overflow-hidden relative">
                      <img src={product.images[0] || 'https://placehold.co/600x400'} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                      <button onClick={(e) => handleAddToCart(e, product)} className="absolute bottom-4 right-4 bg-white p-3 rounded-full shadow-xl hover:bg-black hover:text-white transition-all"><ShoppingCart size={18} /></button>
                    </div>
                    <div className="p-5">
                      <h3 className="font-bold text-lg mb-1 line-clamp-1">{product.name}</h3>
                      <p className="text-sm text-gray-500 line-clamp-2 mb-4">{product.description}</p>
                      <div className="flex flex-col">
                        {product.discount > 0 && <span className="text-xs text-gray-400 line-through">Rp {product.price.toLocaleString()}</span>}
                        <span className="font-bold text-lg">Rp {(product.price * (1 - product.discount / 100)).toLocaleString()}</span>
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
