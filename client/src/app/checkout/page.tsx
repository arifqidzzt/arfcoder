'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { ShieldCheck, Truck, CreditCard, ArrowRight, MapPin } from 'lucide-react';
import AuthGuard from '@/components/AuthGuard';

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
  const [isMobile, setIsMobile] = useState(false); // Deteksi HP
  const router = useRouter();

  // Payment Settings
  const [paymentMode, setPaymentMode] = useState("SNAP");
  const [availableMethods, setAvailableMethods] = useState<string[]>([]);
  const [selectedMethod, setSelectedMethod] = useState<string>("");

  // Voucher States
  const [voucherInput, setVoucherInput] = useState('');
  const [discount, setDiscount] = useState(0);
  const [appliedVoucher, setAppliedVoucher] = useState<string | null>(null);

  useEffect(() => {
    // Deteksi Perangkat yang lebih akurat (Termasuk Android Mode Desktop)
    const checkMobile = () => {
      const isTouch = navigator.maxTouchPoints > 0;
      const isMobileUA = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
      // Jika punya Touch Point dan bukan Windows PC murni, anggap Mobile
      setIsMobile(isMobileUA || (isTouch && !navigator.userAgent.includes("Windows NT")));
    };
    checkMobile();
    
    fetchPaymentSettings();
    const script = document.createElement('script');
// ... existing script logic ...
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);
  }, [router]); // Kurangi dependency agar tidak trigger saat items kosong

  const fetchPaymentSettings = async () => {
    try {
      const { data: settings } = await api.get("/admin/payment-settings");
      setPaymentMode(settings.mode);
      
      let methods = settings.activeMethods || [];
      
      // Check for product overrides
      // For simplicity, if any product has overrides, we intersect them.
      // If product has empty array, it uses global.
      for (const item of items) {
        const pMethods = item.paymentMethods;
        if (pMethods && pMethods.length > 0) {
          methods = methods.filter((m: string) => pMethods.includes(m));
        }
      }
      
      setAvailableMethods(methods);
    } catch (error) {}
  };

  const getMethodDetails = (id: string) => {
    const map: any = {
      bca_va: { name: "BCA Virtual Account", type: "bank_transfer", method: "bca", isEWallet: false },
      bni_va: { name: "BNI Virtual Account", type: "bank_transfer", method: "bni", isEWallet: false },
      bri_va: { name: "BRI Virtual Account", type: "bank_transfer", method: "bri", isEWallet: false },
      mandiri_va: { name: "Mandiri VA", type: "echannel", method: "mandiri", isEWallet: false },
      permata_va: { name: "Permata VA", type: "bank_transfer", method: "permata", isEWallet: false },
      qris: { name: "QRIS", type: "qris", method: "qris", isEWallet: false },
      gopay: { name: "GoPay", type: "gopay", method: "gopay", isEWallet: true },
      shopeepay: { name: "ShopeePay", type: "shopeepay", method: "shopeepay", isEWallet: true },
      dana: { name: "DANA", type: "dana", method: "dana", isEWallet: true },
    };
    return map[id] || { name: id, type: id, method: id, isEWallet: false };
  };

  const handleApplyVoucher = async () => {
// ... existing voucher logic ...
  };

  const handleCheckout = async () => {
    if (!user) return toast.error('Silakan login');
    if (!address) return toast.error('Alamat/Catatan harus diisi');
    if (paymentMode === "CORE" && !selectedMethod) return toast.error('Silakan pilih metode pembayaran');

    setLoading(true);
    try {
      const methodDetails = selectedMethod ? getMethodDetails(selectedMethod) : null;
      
      const res = await api.post('/orders', {
        items: items.map(i => ({ productId: i.id, quantity: i.quantity })),
        address,
        voucherCode: appliedVoucher,
        paymentType: methodDetails?.type,
        paymentMethod: methodDetails?.method
      });

      const orderId = res.data.order.id;
      clearCart();

      if (paymentMode === "CORE") {
        toast.success('Pesanan dibuat!');
        router.push(`/orders/${orderId}`);
        return;
      }

      const { snapToken } = res.data;
      if (snapToken && window.snap) {
        window.snap.pay(snapToken, {
          onSuccess: () => { 
            toast.success('Pembayaran Berhasil!'); 
            window.location.href = `/orders/${orderId}`; 
          },
          onPending: () => { 
            toast('Menunggu pembayaran...'); 
            router.push(`/orders/${orderId}`); 
          },
          onError: () => { 
            toast.error('Pembayaran Gagal'); 
            router.push(`/orders/${orderId}`);
          },
          onClose: () => { 
            toast('Selesaikan pembayaran di menu Pesanan'); 
            router.push(`/orders/${orderId}`); 
          }
        });
      }
    } catch (error: any) {
      toast.error('Gagal memproses pesanan');
      setLoading(false);
    }
  };

  return (
    <AuthGuard>
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

            {/* Payment Method Section (CORE) */}
            {paymentMode === "CORE" && (
              <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                <div className="flex items-center gap-2 mb-6 text-accent">
                  <CreditCard size={20} />
                  <h2 className="font-bold uppercase tracking-wider text-sm">Pilih Metode Pembayaran</h2>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {availableMethods.map((m) => {
                    const details = getMethodDetails(m);
                    const isDisabled = !isMobile && details.isEWallet; // Nonaktifkan jika desktop dan e-wallet

                    return (
                      <button
                        key={m}
                        onClick={() => {
                          if (isDisabled) {
                            toast.error("Metode ini hanya tersedia jika Anda mengakses website melalui Smartphone (Android/iOS).", {
                              position: "bottom-center",
                              duration: 4000,
                            });
                            return;
                          }
                          setSelectedMethod(m);
                        }}
                        className={`flex items-center justify-between p-4 rounded-2xl border-2 transition-all ${
                          isDisabled 
                            ? "bg-gray-50 border-gray-100 opacity-60 cursor-pointer" 
                            : selectedMethod === m
                              ? "border-black bg-gray-50"
                              : "border-gray-50 hover:border-gray-100"
                        }`}
                      >
                        <div className="flex flex-col items-start">
                          <span className="font-bold text-sm">{details.name}</span>
                          {isDisabled && <span className="text-[9px] text-red-500 font-medium uppercase">Hanya di HP</span>}
                        </div>
                        {selectedMethod === m && <div className="w-4 h-4 bg-black rounded-full" />}
                      </button>
                    );
                  })}
                  {availableMethods.length === 0 && (
                    <p className="text-sm text-gray-500 col-span-2 italic">Tidak ada metode pembayaran tersedia untuk kombinasi produk ini.</p>
                  )}
                </div>
              </div>
            )}
          </div>

          {/* Payment Summary Sidebar */}
          <div className="space-y-6">
            <div className="bg-white p-8 rounded-3xl shadow-lg border border-gray-100 sticky top-24">
              <h2 className="text-xl font-bold mb-6">Ringkasan</h2>
              
              {/* Voucher Input */}
              <div className="mb-6">
                <label className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 block">Punya Kode Promo?</label>
                <div className="flex flex-col sm:flex-row gap-2">
                  <input 
                    type="text" 
                    value={voucherInput}
                    onChange={(e) => setVoucherInput(e.target.value.toUpperCase())}
                    className="w-full sm:flex-1 bg-gray-50 border border-gray-100 px-4 py-3 rounded-xl text-sm focus:outline-none focus:border-black font-bold"
                    placeholder="KODE100"
                    disabled={!!appliedVoucher}
                  />
                  {appliedVoucher ? (
                    <button 
                      onClick={() => {setAppliedVoucher(null); setDiscount(0); setVoucherInput('');}}
                      className="w-full sm:w-auto px-6 py-3 bg-red-50 text-red-500 rounded-xl text-xs font-bold hover:bg-red-100 whitespace-nowrap"
                    >
                      Hapus
                    </button>
                  ) : (
                    <button 
                      onClick={handleApplyVoucher}
                      className="w-full sm:w-auto px-6 py-3 bg-black text-white rounded-xl text-xs font-bold hover:bg-gray-800 whitespace-nowrap"
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
    </AuthGuard>
  );
}
