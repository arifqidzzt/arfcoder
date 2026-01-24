'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';

declare global {
  interface Window {
    snap: any;
  }
}

export default function CheckoutPage() {
  const { items, total, clearCart } = useCartStore();
  const { user, token } = useAuthStore();
  const [address, setAddress] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  useEffect(() => {
    // Load Midtrans Snap script
    const script = document.createElement('script');
    script.src = "https://app.sandbox.midtrans.com/snap/snap.js";
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);

    if (items.length === 0) {
      router.push('/cart');
    }
  }, [items, router]);

  const handleCheckout = async () => {
    if (!user) {
      toast.error('Silakan login terlebih dahulu');
      router.push('/login');
      return;
    }

    if (!address) {
      toast.error('Alamat harus diisi');
      return;
    }

    setLoading(true);
    try {
      // In real app: call API to create order and get snap token
      // For demo: simulation
      setTimeout(() => {
        setLoading(false);
        // This is where window.snap.pay(token) would be called
        toast.success('Pemesanan berhasil (Simulasi)');
        clearCart();
        router.push('/');
      }, 2000);
    } catch (error) {
      toast.error('Terjadi kesalahan saat checkout');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-8 py-12">
        <h1 className="text-4xl font-bold mb-12 tracking-tight">Checkout</h1>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-24">
          <div className="space-y-12">
            <section>
              <h2 className="text-xs font-bold uppercase tracking-widest mb-6 pb-2 border-b border-gray-100">Informasi Pengiriman</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm text-gray-500 mb-2">Nama Lengkap</label>
                  <input 
                    type="text" 
                    disabled 
                    value={user?.name || ''} 
                    className="w-full px-4 py-3 border border-gray-100 bg-gray-50 text-gray-400"
                  />
                </div>
                <div>
                  <label className="block text-sm text-gray-500 mb-2">Alamat Lengkap</label>
                  <textarea 
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    rows={4}
                    className="w-full px-4 py-3 border border-gray-200 focus:outline-none focus:border-black transition-colors"
                    placeholder="Masukkan alamat pengiriman atau detail jasa..."
                  />
                </div>
              </div>
            </section>

            <section>
              <h2 className="text-xs font-bold uppercase tracking-widest mb-6 pb-2 border-b border-gray-100">Metode Pembayaran</h2>
              <div className="p-4 border border-black bg-black text-white text-sm font-medium">
                Midtrans Secure Payment (QRIS, Bank Transfer, Card)
              </div>
            </section>
          </div>

          <div className="bg-gray-50 p-8 h-fit">
            <h2 className="text-xl font-bold mb-6">Ringkasan Pesanan</h2>
            <div className="space-y-4 mb-8">
              {items.map((item) => (
                <div key={item.id} className="flex justify-between text-sm">
                  <span className="text-gray-600">{item.name} x {item.quantity}</span>
                  <span className="font-medium">Rp {(item.price * item.quantity).toLocaleString('id-ID')}</span>
                </div>
              ))}
              <div className="pt-4 border-t border-gray-200 flex justify-between font-bold text-lg">
                <span>Total</span>
                <span>Rp {total().toLocaleString('id-ID')}</span>
              </div>
            </div>
            <button 
              onClick={handleCheckout}
              disabled={loading}
              className="w-full py-4 bg-black text-white font-medium flex items-center justify-center space-x-2 hover:bg-gray-800 transition-colors disabled:bg-gray-400"
            >
              {loading ? 'Memproses...' : 'Bayar Sekarang'}
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}
