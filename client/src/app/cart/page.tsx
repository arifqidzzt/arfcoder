'use client';

import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { Trash2, Plus, Minus, ArrowRight } from 'lucide-react';
import Link from 'next/link';

export default function CartPage() {
  const { items, removeItem, updateQuantity, total } = useCartStore();

  if (items.length === 0) {
    return (
      <div className="min-h-screen bg-white">
        <Navbar />
        <main className="max-w-7xl mx-auto px-8 py-32 text-center">
          <h1 className="text-4xl font-bold mb-4">Keranjang Kosong</h1>
          <p className="text-gray-500 mb-8">Anda belum menambahkan produk apapun ke keranjang.</p>
          <Link href="/products" className="inline-flex items-center space-x-2 px-8 py-4 bg-black text-white font-medium hover:bg-gray-800 transition-colors">
            <span>Mulai Belanja</span>
            <ArrowRight size={18} />
          </Link>
        </main>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-8 py-12">
        <h1 className="text-4xl font-bold mb-12 tracking-tight">Keranjang Belanja</h1>
        
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-16">
          <div className="lg:col-span-2 space-y-8">
            {items.map((item) => (
              <div key={item.id} className="flex gap-6 pb-8 border-b border-gray-100 last:border-0">
                <div className="w-24 h-24 bg-gray-100 flex-shrink-0">
                  {item.image && <img src={item.image} alt={item.name} className="w-full h-full object-cover" />}
                </div>
                <div className="flex-grow">
                  <div className="flex justify-between mb-2">
                    <h3 className="font-bold">{item.name}</h3>
                    <button onClick={() => removeItem(item.id)} className="text-gray-400 hover:text-black transition-colors">
                      <Trash2 size={18} />
                    </button>
                  </div>
                  <p className="text-sm text-gray-500 mb-4">Rp {item.price.toLocaleString('id-ID')}</p>
                  <div className="flex items-center space-x-4">
                    <div className="flex items-center border border-gray-200">
                      <button 
                        onClick={() => updateQuantity(item.id, Math.max(1, item.quantity - 1))}
                        className="p-2 hover:bg-gray-50 transition-colors"
                      >
                        <Minus size={14} />
                      </button>
                      <span className="w-8 text-center text-sm font-medium">{item.quantity}</span>
                      <button 
                        onClick={() => updateQuantity(item.id, item.quantity + 1)}
                        className="p-2 hover:bg-gray-50 transition-colors"
                      >
                        <Plus size={14} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="bg-gray-50 p-8 h-fit">
            <h2 className="text-xl font-bold mb-6">Ringkasan Pesanan</h2>
            <div className="space-y-4 mb-8">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Subtotal</span>
                <span>Rp {total().toLocaleString('id-ID')}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Biaya Layanan</span>
                <span>Gratis</span>
              </div>
              <div className="pt-4 border-t border-gray-200 flex justify-between font-bold text-lg">
                <span>Total</span>
                <span>Rp {total().toLocaleString('id-ID')}</span>
              </div>
            </div>
            <Link href="/checkout" className="w-full py-4 bg-black text-white font-medium flex items-center justify-center space-x-2 hover:bg-gray-800 transition-colors">
              <span>Lanjut ke Checkout</span>
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
