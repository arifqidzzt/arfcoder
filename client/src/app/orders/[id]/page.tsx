'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { ArrowLeft, Copy, Download, CreditCard, Activity, CheckCircle2, Loader2 } from 'lucide-react';
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
  const [order, setOrder] = useState<OrderDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [successRedirect, setSuccessRedirect] = useState(false);
  const [countdown, setCountdown] = useState(3);
  const { user, token, hasHydrated } = useAuthStore();
  const { t } = useTranslation();
  const router = useRouter();

  useEffect(() => {
    if (!hasHydrated) return;
    if (!token) { router.replace('/login'); return; }
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
      setTimeout(() => {
        const currentUser = useAuthStore.getState().user;
        if (currentUser && currentUser.role !== 'ADMIN' && currentUser.role !== 'SUPER_ADMIN' && res.data.userId !== currentUser.id) {
          router.replace('/orders');
        }
      }, 100);
      setOrder(res.data);
    } catch (error: any) {
      if (error.response?.status === 403 || error.response?.status === 401) {
        router.replace('/login');
      } else {
        toast.error('Error loading order');
      }
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
          if (prev <= 1) {
            clearInterval(timer);
            router.push('/orders');
            return 0;
          }
          return prev - 1;
        });
      }
    }, 1000);
  };

  const handleCancel = () => {
    toast((t_toast) => (
      <div className="flex flex-col gap-3 min-w-[240px]">
        <span className="font-bold text-sm">{t('cart.remove_confirm')}</span>
        <div className="flex gap-2 justify-end mt-2">
          <button onClick={() => toast.dismiss(t_toast.id)} className="px-4 py-2 bg-gray-50 rounded-xl text-xs font-bold">{t('cart.cancel')}</button>
          <button 
            onClick={async () => {
              toast.dismiss(t_toast.id);
              try {
                await api.put(`/orders/${id}/cancel`, {});
                toast.success('Cancelled');
                fetchOrder();
              } catch (error) { toast.error('Failed'); }
            }} 
            className="px-4 py-2 bg-red-600 text-white rounded-xl text-xs font-bold"
          >
            {t('cart.delete')}
          </button>
        </div>
      </div>
    ), { position: "top-center" });
  };

  if (!hasHydrated || loading) return <div className="min-h-screen bg-gray-50 flex items-center justify-center font-bold">Loading...</div>;
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
          <div><h1 className="text-xl font-bold">{t('orders.title')}</h1><p className="text-sm text-gray-500">Invoice: {order.invoiceNumber}</p></div>
        </div>

        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center">
              <span className="text-sm text-gray-500 mr-2">{t('orders.status')}</span>
              {order.status === 'PENDING' && <CountdownTimer dateString={order.createdAt} expiryTime={order.paymentDetails?.expiry_time} />}
            </div>
            <span className={`px-3 py-1 rounded-full text-xs font-bold ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>{order.status}</span>
          </div>

          {order.status === "PENDING" && order.paymentDetails && (
            <div className="mb-6 bg-gray-50 p-6 rounded-2xl border border-dashed border-gray-200">
              <h3 className="text-sm font-bold text-gray-400 uppercase mb-4 flex items-center gap-2"><CreditCard size={16} /> {t('orders.instruction')}</h3>
              
              {order.paymentDetails.va_number && (
                <div className="space-y-4">
                  <p className="text-xs text-gray-500 mb-1">VA Number ({order.paymentDetails.bank?.toUpperCase()})</p>
                  <div className="flex items-center justify-between bg-white p-4 rounded-xl border">
                    <span className="text-xl font-mono font-bold">{order.paymentDetails.va_number}</span>
                    <button onClick={() => {navigator.clipboard.writeText(order.paymentDetails?.va_number || ""); toast.success(t('orders.copy'))}} className="text-blue-600"><Copy size={18} /></button>
                  </div>
                </div>
              )}

              {order.paymentDetails.qr_url && (
                <div className="flex flex-col items-center">
                  {!( (order.paymentType === 'gopay' || order.paymentType === 'shopeepay' || order.paymentType === 'dana') && order.paymentDetails.deeplink ) && (
                    <>
                      <p className="text-xs text-gray-500 mb-4">{t('orders.scan_qr')}</p>
                      <div className="bg-white p-4 rounded-2xl border"><img src={order.paymentDetails.qr_url} className="w-48 h-48" /></div>
                    </>
                  )}
                  {order.paymentDetails.deeplink && (
                    <a href={order.paymentDetails.deeplink} className={`mt-4 px-8 py-3 text-white rounded-xl font-bold ${order.paymentType === 'gopay' ? 'bg-[#00AABB]' : order.paymentType === 'shopeepay' ? 'bg-[#EE4D2D]' : 'bg-[#118EEA]'}`}>
                      {t('orders.open_app')} {order.paymentType?.toUpperCase()}
                    </a>
                  )}
                </div>
              )}
            </div>
          )}
          {order.status === 'PENDING' && <button onClick={handleCancel} className="w-full bg-white border border-red-200 text-red-600 py-3 rounded-lg font-bold">{t('orders.cancel_order')}</button>}
        </div>

        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <h3 className="font-bold mb-4">{t('orders.items')}</h3>
          {order.items.map((item, idx) => (
            <div key={idx} className="flex gap-4 border-b last:border-0 pb-4 last:pb-0 mb-4 last:mb-0">
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