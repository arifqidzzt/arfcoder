'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { Trash2, Plus, Minus, ArrowRight, ShoppingBag } from 'lucide-react';
import Link from 'next/link';

export default function CartPage() {
  const { items, removeItem, updateQuantity, total, fetchCart } = useCartStore();
  const { token } = useAuthStore();
  const [isRefreshing, setIsRefreshing] = useState(false);

  useEffect(() => {
    if (token) fetchCart();
  }, [token]);

  const handleUpdateQuantity = async (id: string, newQty: number) => {
    setIsRefreshing(true);
    await updateQuantity(id, newQty);
    setIsRefreshing(false);
  };

  const handleRemove = async (id: string) => {
    if (confirm('Hapus item ini?')) {
      setIsRefreshing(true);
      await removeItem(id);
      setIsRefreshing(false);
    }
  };

  if (items.length === 0) {
    return (
      <div className="min-h-screen bg-white">
        <Navbar />
        <main className="max-w-7xl mx-auto px-8 py-32 text-center">
          <div className="bg-gray-50 w-24 h-24 rounded-full flex items-center justify-center mx-auto mb-6">
            <ShoppingBag size={40} className="text-gray-300"/>
          </div>
          <h1 className="text-2xl font-bold mb-2">Keranjang Belanja Kosong</h1>
          <p className="text-gray-500 mb-8">Wah, keranjangmu masih kosong nih. Yuk isi dengan produk keren!</p>
          <Link href="/products" className="inline-flex items-center space-x-2 px-8 py-3 bg-black text-white font-medium rounded-full hover:bg-gray-800 transition-colors">
            <span>Mulai Belanja</span>
            <ArrowRight size={18} />
          </Link>
        </main>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />
      <main className="max-w-6xl mx-auto px-4 sm:px-8 py-12 pt-24">
        <div className="flex justify-between items-end mb-8">
          <h1 className="text-3xl font-bold">Keranjang Belanja ({items.length})</h1>
          {isRefreshing && <span className="text-xs text-gray-400 animate-pulse font-medium">Memperbarui...</span>}
        </div>
        
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Cart Items */}
          <div className="lg:col-span-2 space-y-4">
            {items.map((item) => (
              <div key={item.id} className={`bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex gap-6 items-center transition-opacity ${isRefreshing ? 'opacity-50' : 'opacity-100'}`}>
                <div className="w-24 h-24 bg-gray-100 rounded-xl overflow-hidden flex-shrink-0">
                  {item.image && <img src={item.image} alt={item.name} className="w-full h-full object-cover" />}
                </div>
                
                <div className="flex-grow min-w-0">
                  <h3 className="font-bold text-lg mb-1 truncate">{item.name}</h3>
                  <p className="text-sm font-medium text-gray-500 mb-4">Rp {item.price.toLocaleString('id-ID')}</p>
                  
                  <div className="flex items-center gap-4">
                    <div className="flex items-center bg-gray-50 rounded-lg border border-gray-200">
                      <button 
                        onClick={() => handleUpdateQuantity(item.id, Math.max(1, item.quantity - 1))}
                        disabled={isRefreshing}
                        className="p-2 hover:bg-gray-200 rounded-l-lg transition-colors disabled:opacity-50"
                      >
                        <Minus size={14} />
                      </button>
                      <span className="w-8 text-center text-sm font-bold">{item.quantity}</span>
                      <button 
                        onClick={() => handleUpdateQuantity(item.id, item.quantity + 1)}
                        disabled={isRefreshing}
                        className="p-2 hover:bg-gray-200 rounded-r-lg transition-colors disabled:opacity-50"
                      >
                        <Plus size={14} />
                      </button>
                    </div>
                    <button 
                      onClick={() => handleRemove(item.id)} 
                      disabled={isRefreshing}
                      className="p-2 text-gray-400 hover:text-red-500 transition-colors disabled:opacity-50"
                      title="Hapus"
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Summary Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 sticky top-24">
              <h2 className="text-xl font-bold mb-6">Ringkasan</h2>
              <div className="space-y-3 mb-6 border-b border-gray-50 pb-6">
                <div className="flex justify-between text-sm text-gray-500">
                  <span>Subtotal</span>
                  <span>Rp {total().toLocaleString('id-ID')}</span>
                </div>
                <div className="flex justify-between text-sm text-gray-500">
                  <span>Pajak & Biaya</span>
                  <span className="text-green-600 font-bold">Rp 0</span>
                </div>
              </div>
              
              <div className="flex justify-between items-center mb-8">
                <span className="font-bold text-lg">Total</span>
                <span className="font-black text-2xl">Rp {total().toLocaleString('id-ID')}</span>
              </div>

              <Link href="/checkout" className="w-full py-4 bg-black text-white font-bold rounded-xl flex items-center justify-center space-x-2 hover:bg-gray-800 transition-all hover:scale-[1.02] active:scale-95 shadow-lg shadow-black/20">
                <span>Checkout Sekarang</span>
                <ArrowRight size={18} />
              </Link>
              
              <p className="text-center text-xs text-gray-400 mt-4">
                Transaksi aman & terenkripsi.
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}