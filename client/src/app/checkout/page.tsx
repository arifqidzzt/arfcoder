'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { ShieldCheck, Truck, CreditCard, ArrowRight, MapPin } from 'lucide-react';

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

  // Voucher States
  const [voucherInput, setVoucherInput] = useState('');
  const [discount, setDiscount] = useState(0);
  const [appliedVoucher, setAppliedVoucher] = useState<string | null>(null);

  useEffect(() => {
    const script = document.createElement('script');
    script.src = "https://app.sandbox.midtrans.com/snap/snap.js";
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);

    if (items.length === 0) router.push('/cart');
  }, [items, router]);

  const handleApplyVoucher = async () => {
    if (!voucherInput) return;
    try {
      const res = await api.post('/vouchers/check', {
        code: voucherInput,
        totalAmount: total()
      });
      setDiscount(res.data.discountAmount);
      setAppliedVoucher(voucherInput);
      toast.success('Voucher berhasil dipasang!');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Voucher tidak valid');
      setDiscount(0);
      setAppliedVoucher(null);
    }
  };

  const handleCheckout = async () => {
    if (!user) return toast.error('Silakan login');
    if (!address) return toast.error('Alamat/Catatan harus diisi');

    setLoading(true);
    try {
      const res = await api.post('/orders', {
        items: items.map(i => ({ productId: i.id, quantity: i.quantity })),
        address,
        voucherCode: appliedVoucher
      });

      const { snapToken } = res.data;
      if (snapToken && window.snap) {
        window.snap.pay(snapToken, {
          onSuccess: () => { 
            toast.success('Pembayaran Berhasil!'); 
            clearCart(); 
            window.location.href = '/orders'; 
          },
          onPending: () => { 
            toast('Menunggu pembayaran...'); 
            clearCart(); 
            router.push('/orders'); 
          },
          onError: () => { toast.error('Pembayaran Gagal'); setLoading(false); },
          onClose: () => { 
            toast('Selesaikan pembayaran di menu Pesanan'); 
            clearCart(); 
            router.push('/orders'); 
          }
        });
      }
    } catch (error: any) {
      toast.error('Gagal memproses pesanan');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <main className="max-w-6xl mx-auto px-4 py-24 w-full">
        <div className="flex items-center gap-3 mb-8">
          <div className="w-10 h-10 bg-black text-white rounded-full flex items-center justify-center font-bold">1</div>
          <h1 className="text-3xl font-bold tracking-tight">Konfirmasi Pesanan</h1>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-6">
            {/* Address Section */}
            <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
              <div className="flex items-center gap-2 mb-6 text-accent">
                <MapPin size={20} />
                <h2 className="font-bold uppercase tracking-wider text-sm">Alamat Pengiriman / Catatan Jasa</h2>
              </div>
              <textarea 
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                rows={4}
                className="w-full p-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-accent/20 transition-all"
                placeholder="Contoh: Jl. Sudirman No. 1 atau detail khusus untuk jasa koding..."
              />
            </div>

            {/* Items Section */}
            <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
              <div className="flex items-center gap-2 mb-6">
                <Truck size={20} />
                <h2 className="font-bold uppercase tracking-wider text-sm">Rincian Produk</h2>
              </div>
              <div className="space-y-4">
                {items.map((item) => (
                  <div key={item.id} className="flex gap-4 py-4 border-b border-gray-50 last:border-0">
                    <img src={item.image} className="w-20 h-20 rounded-xl object-cover bg-gray-100" />
                    <div className="flex-1">
                      <h3 className="font-bold text-sm">{item.name}</h3>
                      <p className="text-xs text-gray-400 mt-1">{item.quantity} Barang</p>
                    </div>
                    <p className="font-bold text-sm">Rp {(item.price * item.quantity).toLocaleString()}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Payment Summary Sidebar */}
          <div className="space-y-6">
            <div className="bg-white p-8 rounded-3xl shadow-lg border border-gray-100 sticky top-24">
              <h2 className="text-xl font-bold mb-6">Ringkasan</h2>
              
              {/* Voucher Input */}
              <div className="mb-6">
                <label className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 block">Punya Kode Promo?</label>
                <div className="flex gap-2">
                  <input 
                    type="text" 
                    value={voucherInput}
                    onChange={(e) => setVoucherInput(e.target.value.toUpperCase())}
                    className="flex-1 bg-gray-50 border border-gray-100 px-4 py-2 rounded-xl text-sm focus:outline-none focus:border-black font-bold"
                    placeholder="KODE100"
                    disabled={!!appliedVoucher}
                  />
                  {appliedVoucher ? (
                    <button 
                      onClick={() => {setAppliedVoucher(null); setDiscount(0); setVoucherInput('');}}
                      className="px-4 py-2 bg-red-50 text-red-500 rounded-xl text-xs font-bold hover:bg-red-100"
                    >
                      Hapus
                    </button>
                  ) : (
                    <button 
                      onClick={handleApplyVoucher}
                      className="px-4 py-2 bg-black text-white rounded-xl text-xs font-bold hover:bg-gray-800"
                    >
                      Pasang
                    </button>
                  )}
                </div>
              </div>

              <div className="space-y-4 mb-8">
                <div className="flex justify-between text-gray-500 text-sm">
                  <span>Total Harga ({items.length} Barang)</span>
                  <span>Rp {total().toLocaleString()}</span>
                </div>
                {discount > 0 && (
                  <div className="flex justify-between text-green-600 text-sm font-bold">
                    <span>Potongan Voucher</span>
                    <span>-Rp {discount.toLocaleString()}</span>
                  </div>
                )}
                <div className="flex justify-between text-gray-500 text-sm">
                  <span>Biaya Layanan</span>
                  <span className="text-green-600 font-bold uppercase text-[10px] bg-green-50 px-2 py-0.5 rounded">Gratis</span>
                </div>
                <div className="pt-4 border-t flex justify-between items-center">
                  <span className="font-medium">Total Bayar</span>
                  <span className="text-2xl font-black text-accent">Rp {(total() - discount).toLocaleString()}</span>
                </div>
              </div>

              <div className="bg-blue-50 p-4 rounded-2xl mb-8 flex items-start gap-3">
                <ShieldCheck className="text-blue-600 shrink-0" size={20} />
                <p className="text-[10px] text-blue-700 leading-relaxed">
                  Pembayaran Anda aman dan terenkripsi melalui payment gateway Midtrans.
                </p>
              </div>

              <button 
                onClick={handleCheckout}
                disabled={loading}
                className="w-full py-4 bg-black text-white rounded-2xl font-bold hover:bg-gray-800 transition-all flex items-center justify-center gap-2 active:scale-95 disabled:bg-gray-300 shadow-xl shadow-black/10"
              >
                {loading ? 'Memproses...' : 'Buat Pesanan'} <ArrowRight size={18} />
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
