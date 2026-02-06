'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { ArrowLeft, Copy, Download, CreditCard, Activity, CheckCircle2, Loader2, AlertCircle, XCircle, ArrowRight } from 'lucide-react';
import toast from 'react-hot-toast';
import { useTranslation } from '@/lib/i18n';

interface OrderDetail {
  id: string;
  userId: string;
  invoiceNumber: string;
  totalAmount: number;
  status: string;
  paymentType?: string;
  paymentMethod?: string;
  paymentDetails?: {
    va_number?: string;
    bank?: string;
    qr_url?: string;
    deeplink?: string;
    bill_key?: string;
    biller_code?: string;
    expiry_time?: string;
  };
  snapToken?: string;
  deliveryInfo?: string;
  refundReason?: string;
  refundAccount?: string; 
  createdAt: string;
  items: {
    product: { name: string; images: string[]; type: string };
    quantity: number;
    price: number;
  }[];
  timeline?: {
    title: string;
    description: string;
    timestamp: string;
  }[];
}

const CountdownTimer = ({ dateString, expiryTime }: { dateString: string; expiryTime?: string }) => {
  const { t } = useTranslation();
  const [timeLeft, setTimeLeft] = useState('');
  useEffect(() => {
    const target = expiryTime ? new Date(expiryTime).getTime() : new Date(dateString).getTime() + 24 * 60 * 60 * 1000;
    const interval = setInterval(() => {
      const now = new Date().getTime();
      const distance = target - now;
      if (distance < 0) { setTimeLeft('Expired'); clearInterval(interval); }
      else {
        const h = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const m = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const s = Math.floor((distance % (1000 * 60)) / 1000);
        setTimeLeft(`${h}j ${m}m ${s}s`);
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [dateString, expiryTime]);
  return <span className="ml-2 text-red-500 text-xs font-bold bg-red-50 px-2 py-1 rounded">{t('orders.limit')}: {timeLeft}</span>;
};

export default function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { t } = useTranslation();
  const [order, setOrder] = useState<OrderDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [successRedirect, setSuccessRedirect] = useState(false);
  const [countdown, setCountdown] = useState(3);
  const { token, hasHydrated } = useAuthStore();
  const router = useRouter();

  // Refund States
  const [refundReason, setRefundReason] = useState('');
  const [refundAccount, setRefundAccount] = useState('');
  const [showRefundForm, setShowRefundForm] = useState(false);

  useEffect(() => {
    if (!hasHydrated) return;
    if (!token) { router.replace('/login'); return; }
    
    // Load Midtrans Snap Script (Just in case mode is SNAP)
    const script = document.createElement('script');
    const isProduction = process.env.NEXT_PUBLIC_MIDTRANS_IS_PRODUCTION === 'true';
    script.src = isProduction ? "https://app.midtrans.com/snap/snap.js" : "https://app.sandbox.midtrans.com/snap/snap.js";
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);

    fetchOrder();
  }, [id, token, hasHydrated]);

  useEffect(() => {
    if (!hasHydrated || !token || order?.status !== 'PENDING') return;
    const pollInterval = setInterval(() => { checkStatusOnly(); }, 3000);
    return () => clearInterval(pollInterval);
  }, [id, token, hasHydrated, order?.status]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      const res = await api.get(`/orders/${id}`);
      setOrder(res.data);
    } catch (error: any) {
      toast.error('Error loading order');
      router.push('/orders');
    } finally {
      setLoading(false);
    }
  };

  const checkStatusOnly = async () => {
    try {
      const res = await api.get(`/orders/${id}`);
      if (res.data.status === 'PAID') {
        setOrder(res.data);
        setSuccessRedirect(true);
        startRedirectCountdown();
      }
    } catch (e) {}
  };

  const startRedirectCountdown = () => {
    const timer = setInterval(() => {
      if (document.visibilityState === 'visible') {
        setCountdown((prev) => {
          if (prev <= 1) { clearInterval(timer); router.push('/orders'); return 0; }
          return prev - 1;
        });
      }
    }, 1000);
  };

  const handlePaySnap = () => {
    if (order?.snapToken && (window as any).snap) {
      (window as any).snap.pay(order.snapToken, {
        onSuccess: () => window.location.reload(),
        onPending: () => window.location.reload(),
        onClose: () => toast('Selesaikan pembayaran Anda')
      });
    }
  };

  const handleCancel = () => {
    toast((t_toast) => (
      <div className="flex flex-col gap-3 min-w-[240px]">
        <span className="font-bold text-sm">{t('cart.remove_confirm')}</span>
        <div className="flex gap-2 justify-end mt-2">
          <button onClick={() => toast.dismiss(t_toast.id)} className="px-4 py-2 bg-gray-50 rounded-xl text-xs font-bold">{t('cart.cancel')}</button>
          <button onClick={async () => {
            toast.dismiss(t_toast.id);
            try { await api.put(`/orders/${id}/cancel`, {}); toast.success('Cancelled'); fetchOrder(); } 
            catch (error) { toast.error('Failed'); }
          }} className="px-4 py-2 bg-red-600 text-white rounded-xl text-xs font-bold">{t('cart.delete')}</button>
        </div>
      </div>
    ), { position: "top-center" });
  };

  const handleSubmitRefund = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post(`/orders/${id}/refund`, { reason: refundReason, account: refundAccount });
      toast.success('Refund requested');
      setShowRefundForm(false);
      fetchOrder();
    } catch (error) { toast.error('Failed'); }
  };

  if (!hasHydrated || loading) return <div className="min-h-screen bg-gray-50 flex items-center justify-center font-bold">{t('common.loading')}</div>;
  if (!order) return <div className="min-h-screen bg-gray-50 pt-24 text-center font-bold">Not Found</div>;

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />

      {successRedirect && (
        <div className="fixed inset-0 z-[100] bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-8 max-w-sm w-full text-center shadow-2xl">
            <div className="w-20 h-20 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6"><CheckCircle2 size={48} /></div>
            <h2 className="text-2xl font-black mb-2">{t('orders.success_title')}</h2>
            <p className="text-gray-500 text-sm mb-8">{t('orders.success_desc')}</p>
            <div className="bg-gray-50 rounded-2xl py-4 flex flex-col items-center">
              <Loader2 className="animate-spin text-blue-600 mb-2" size={24} />
              <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">{t('orders.redirecting')} {countdown}s...</p>
            </div>
          </div>
        </div>
      )}

      <main className="max-w-3xl mx-auto px-4 pt-24">
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => router.push('/orders')} className="p-2 bg-white rounded-full border border-gray-100 hover:bg-gray-100"><ArrowLeft size={20} /></button>
          <div><h1 className="text-xl font-bold">{t('orders.title')}</h1><p className="text-sm text-gray-500">{t('orders.invoice')}: {order.invoiceNumber}</p></div>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 mb-6">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center">
              <span className="text-sm text-gray-500 mr-2">{t('orders.status')}</span>
              {order.status === 'PENDING' && <CountdownTimer dateString={order.createdAt} expiryTime={order.paymentDetails?.expiry_time} />}
            </div>
            <span className={`px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider
              ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 
                order.status === 'CANCELLED' ? 'bg-red-100 text-red-700' : 
                order.status === 'PENDING' ? 'bg-orange-100 text-orange-700' : 
                'bg-blue-100 text-blue-700'}`}>
              {order.status}
            </span>
          </div>

          {/* Core API Details - CLEANER */}
          {order.status === "PENDING" && order.paymentDetails && (
            <div className="mb-6 space-y-6 border-t pt-6">
              <div className="p-6 bg-gray-50 rounded-2xl border border-gray-100 text-center">
                <h3 className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4 flex items-center justify-center gap-2">
                  <CreditCard size={14} /> {t('orders.instruction')}
                </h3>
                
                {order.paymentDetails.va_number && (
                  <div className="max-w-xs mx-auto mb-4">
                    <p className="text-[10px] font-black text-gray-400 uppercase mb-2">VA Number ({order.paymentDetails.bank?.toUpperCase()})</p>
                    <div className="flex items-center justify-between bg-white p-4 rounded-xl border">
                      <span className="text-lg font-mono font-bold tracking-widest">{order.paymentDetails.va_number}</span>
                      <button onClick={() => {navigator.clipboard.writeText(order.paymentDetails?.va_number || ""); toast.success(t('orders.copy'))}} className="text-accent">
                        <Copy size={18} />
                      </button>
                    </div>
                  </div>
                )}

                {(order.paymentDetails.qr_url || order.paymentDetails.deeplink) && (
                  <div className="flex flex-col items-center gap-4">
                    {order.paymentDetails.qr_url && !order.paymentDetails.deeplink && (
                      <div className="bg-white p-4 rounded-xl border inline-block mb-2 shadow-sm">
                        <img src={order.paymentDetails.qr_url} className="w-40 h-40" alt="QR Code" />
                      </div>
                    )}
                    
                    {order.paymentDetails.deeplink && (
                      <a href={order.paymentDetails.deeplink} target="_blank" rel="noopener noreferrer" className={`flex items-center gap-3 px-8 py-3 text-white rounded-xl font-bold text-sm shadow-lg transition-transform active:scale-95 ${
                        order.paymentType === 'gopay' ? 'bg-[#00AABB]' : 
                        order.paymentType === 'shopeepay' ? 'bg-[#EE4D2D]' : 'bg-[#118EEA]'
                      }`}>
                        {t('orders.open_app')} {order.paymentType?.toUpperCase()}
                        <ArrowRight size={18} />
                      </a>
                    )}
                  </div>
                )}
              </div>
            </div>
          )}

          {order.status === 'PENDING' && (
            <div className="flex flex-col gap-3">
              {order.snapToken && !order.paymentDetails && (
                <button onClick={handlePaySnap} className="w-full bg-black text-white py-3 rounded-xl font-bold hover:bg-gray-800 transition-colors">
                  Bayar Sekarang (Snap)
                </button>
              )}
              <button onClick={handleCancel} className="w-full bg-white border border-red-100 text-red-600 py-3 rounded-xl font-bold hover:bg-red-50 transition-colors">
                {t('orders.cancel_order')}
              </button>
            </div>
          )}
          {order.status === 'PAID' && !showRefundForm && !order.refundReason && <button onClick={() => setShowRefundForm(true)} className="w-full mt-4 text-xs text-gray-400 underline">{t('orders.refund')}</button>}
        </div>

        {/* Timeline */}
        {order.timeline && order.timeline.length > 0 && (
          <div className="bg-white rounded-xl p-6 border border-gray-100 mb-6">
            <h3 className="font-bold mb-6 flex items-center gap-2 text-accent"><Activity size={18}/> {t('orders.timeline')}</h3>
            <div className="relative pl-4 border-l-2 border-gray-100 space-y-8">
              {order.timeline.map((step, idx) => (
                <div key={idx} className="relative">
                  <div className="absolute -left-[21px] top-0 w-4 h-4 bg-accent rounded-full border-4 border-white"></div>
                  <h4 className="font-bold text-sm">{step.title}</h4>
                  <p className="text-[10px] text-gray-400">{new Date(step.timestamp).toLocaleString()}</p>
                  {step.description && <p className="text-sm text-gray-600 mt-2 bg-gray-50 p-3 rounded-lg border border-gray-100">{step.description}</p>}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Delivery Info */}
        {order.deliveryInfo && (
          <div className="bg-blue-50 rounded-xl p-6 border border-blue-100 mb-6 text-blue-800">
            <h3 className="font-bold mb-2 flex items-center gap-2"><Download size={18}/> {t('orders.delivery')}</h3>
            <div className="bg-white p-4 rounded-lg border border-blue-100 text-sm font-mono">{order.deliveryInfo}</div>
          </div>
        )}

        {/* Refund Form */}
        {showRefundForm && (
          <div className="bg-white rounded-xl p-6 border border-gray-100 mb-6">
            <h3 className="font-bold mb-4">{t('orders.refund_form')}</h3>
            <form onSubmit={handleSubmitRefund} className="space-y-4">
              <textarea required value={refundReason} onChange={e => setRefundReason(e.target.value)} className="w-full p-3 border rounded-lg text-sm" placeholder={t('orders.reason')} />
              <input required value={refundAccount} onChange={e => setRefundAccount(e.target.value)} className="w-full p-3 border rounded-lg text-sm" placeholder={t('orders.account')} />
              <div className="flex justify-end gap-3">
                <button type="button" onClick={() => setShowRefundForm(false)} className="text-sm text-gray-400">Cancel</button>
                <button type="submit" className="bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-bold">{t('orders.submit_refund')}</button>
              </div>
            </form>
          </div>
        )}

        {/* Items List */}
        <div className="bg-white rounded-xl p-6 border border-gray-100">
          <h3 className="font-bold mb-4">{t('orders.items')}</h3>
          {order.items.map((item, idx) => (
            <div key={idx} className="flex gap-4 border-b last:border-0 pb-4 mb-4">
              <img src={item.product.images[0]} className="w-16 h-16 rounded-lg object-cover" />
              <div className="flex-1"><h4 className="font-medium text-sm">{item.product.name}</h4><p className="text-xs text-gray-500">{item.quantity} x Rp {item.price.toLocaleString()}</p></div>
              <p className="font-bold text-sm">Rp {(item.price * item.quantity).toLocaleString()}</p>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
