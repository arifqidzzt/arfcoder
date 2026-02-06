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
import { useTranslation } from '@/lib/i18n';

declare global {
  interface Window {
    snap: any;
  }
}

export default function CheckoutPage() {
  const { items, total, clearCart } = useCartStore();
  const { user, token } = useAuthStore();
  const { t } = useTranslation();
  const [address, setAddress] = useState('');
  const [loading, setLoading] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const router = useRouter();

  const [paymentMode, setPaymentMode] = useState("SNAP");
  const [availableMethods, setAvailableMethods] = useState<string[]>([]);
  const [selectedMethod, setSelectedMethod] = useState<string>("");

  const [voucherInput, setVoucherInput] = useState('');
  const [discount, setDiscount] = useState(0);
  const [appliedVoucher, setAppliedVoucher] = useState<string | null>(null);

  useEffect(() => {
    setIsMobile(/iPhone|iPad|iPod|Android/i.test(navigator.userAgent) || (navigator.maxTouchPoints > 0 && !navigator.userAgent.includes("Windows NT")));
    fetchPaymentSettings();
    const script = document.createElement('script');
    const isProduction = process.env.NEXT_PUBLIC_MIDTRANS_IS_PRODUCTION === 'true';
    script.src = isProduction ? "https://app.midtrans.com/snap/snap.js" : "https://app.sandbox.midtrans.com/snap/snap.js";
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);
  }, []);

  const fetchPaymentSettings = async () => {
    try {
      const { data: settings } = await api.get("/admin/payment-settings");
      setPaymentMode(settings.mode);
      let methods = settings.activeMethods || [];
      for (const item of items) {
        if (item.paymentMethods && item.paymentMethods.length > 0) {
          methods = methods.filter((m: string) => item.paymentMethods?.includes(m));
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
    if (!voucherInput) return;
    try {
      const res = await api.post('/vouchers/check', { code: voucherInput, totalAmount: total() });
      setDiscount(res.data.discountAmount);
      setAppliedVoucher(voucherInput);
      toast.success('Voucher applied!');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Invalid voucher');
    }
  };

  const handleCheckout = async () => {
    if (!user) return toast.error('Please login');
    if (!address) return toast.error('Address is required');
    if (paymentMode === "CORE" && !selectedMethod) return toast.error('Select payment method');

    setLoading(true);
    try {
      const details = selectedMethod ? getMethodDetails(selectedMethod) : null;
      const res = await api.post('/orders', {
        items: items.map(i => ({ productId: i.id, quantity: i.quantity })),
        address,
        voucherCode: appliedVoucher,
        paymentType: details?.type,
        paymentMethod: details?.method
      });

      const orderId = res.data.order.id;
      clearCart();

      if (paymentMode === "CORE") {
        router.push(`/orders/${orderId}`);
        return;
      }

      if (res.data.snapToken && window.snap) {
        window.snap.pay(res.data.snapToken, {
          onSuccess: () => { window.location.href = `/orders/${orderId}`; },
          onPending: () => { router.push(`/orders/${orderId}`); },
          onClose: () => { router.push(`/orders/${orderId}`); }
        });
      }
    } catch (error: any) {
      toast.error('Failed to process order');
      setLoading(false);
    }
  };

  return (
    <AuthGuard>
      <div className="min-h-screen bg-gray-50 flex flex-col">
        <Navbar />
        <main className="max-w-6xl mx-auto px-4 py-24 w-full">
          <h1 className="text-3xl font-bold mb-8">{t('checkout.title')}</h1>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2 space-y-6">
              <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                <h2 className="font-bold uppercase text-sm mb-4 flex items-center gap-2 text-accent"><MapPin size={18}/> {t('checkout.address')}</h2>
                <textarea value={address} onChange={(e) => setAddress(e.target.value)} rows={4} className="w-full p-4 bg-gray-50 border rounded-2xl focus:outline-none" placeholder="..." />
              </div>

              {paymentMode === "CORE" && (
                <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                  <h2 className="font-bold uppercase text-sm mb-6 flex items-center gap-2 text-accent"><CreditCard size={18}/> {t('checkout.select_payment')}</h2>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {availableMethods.map((m) => {
                      const d = getMethodDetails(m);
                      return (
                        <button key={m} onClick={() => setSelectedMethod(m)} className={`flex items-center justify-between p-4 rounded-2xl border-2 transition-all ${selectedMethod === m ? 'border-black bg-gray-50' : 'border-gray-50'}`}>
                          <div className="flex flex-col items-start text-sm font-bold">
                            {d.name}
                          </div>
                          {selectedMethod === m && <div className="w-3 h-3 bg-black rounded-full" />}
                        </button>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>

            <div className="lg:col-span-1 space-y-6">
              <div className="bg-white p-8 rounded-3xl shadow-lg border border-gray-100 sticky top-24">
                <h2 className="text-xl font-bold mb-6">{t('checkout.summary')}</h2>
                
                <div className="mb-6">
                  <label className="text-[10px] font-bold text-gray-400 uppercase mb-2 block">{t('checkout.voucher')}</label>
                  <div className="flex gap-2">
                    <input type="text" value={voucherInput} onChange={(e) => setVoucherInput(e.target.value.toUpperCase())} className="flex-1 bg-gray-50 border p-3 rounded-xl text-sm font-bold min-w-0" placeholder="KODE100" />
                    <button onClick={appliedVoucher ? () => {setAppliedVoucher(null); setDiscount(0);} : handleApplyVoucher} className="px-4 py-3 bg-black text-white rounded-xl text-xs font-bold whitespace-nowrap">{appliedVoucher ? t('checkout.remove') : t('checkout.apply')}</button>
                  </div>
                </div>

                <div className="space-y-4 mb-8 pt-4 border-t">
                  <div className="flex justify-between text-sm text-gray-500"><span>{t('checkout.items')}</span><span>Rp {total().toLocaleString()}</span></div>
                  {discount > 0 && <div className="flex justify-between text-green-600 font-bold text-sm"><span>Discount</span><span>-Rp {discount.toLocaleString()}</span></div>}
                  <div className="flex justify-between items-center pt-4 border-t"><span className="font-bold">Total</span><span className="text-2xl font-black text-accent">Rp {(total() - discount).toLocaleString()}</span></div>
                </div>

                <button onClick={handleCheckout} disabled={loading} className="w-full py-4 bg-black text-white rounded-2xl font-bold flex items-center justify-center gap-2 active:scale-95 disabled:bg-gray-300">
                  {loading ? '...' : t('checkout.create_order')} <ArrowRight size={18} />
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>
    </AuthGuard>
  );
}
