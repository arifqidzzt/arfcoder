'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { ArrowLeft, Copy, Download, CreditCard, Activity, CheckCircle2, Loader2 } from 'lucide-react';
import toast from 'react-hot-toast';

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
        setTimeLeft(`${h}j ${m}m ${s}d`);
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [dateString, expiryTime]);
  return <span className="ml-2 text-red-500 text-xs font-bold bg-red-50 px-2 py-1 rounded">Batas: {timeLeft}</span>;
};

export default function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [order, setOrder] = useState<OrderDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [successRedirect, setSuccessRedirect] = useState(false);
  const [countdown, setCountdown] = useState(3);
  const { user, token, hasHydrated } = useAuthStore();
  const router = useRouter();

  // 1. Logika Sinkronisasi Auth (Hydration)
  useEffect(() => {
    // Jangan lakukan apapun sebelum data localStorage terisi kembali ke Store
    if (!hasHydrated) return;

    // Setelah Hydrated, baru cek apakah benar-benar ada token
    if (!token) {
      router.replace('/login');
      return;
    }

    fetchOrder();
  }, [id, token, hasHydrated]);

  // 2. Polling Status (Terpisah agar tidak reset fetchOrder)
  useEffect(() => {
    if (!hasHydrated || !token || order?.status !== 'PENDING') return;

    const pollInterval = setInterval(() => {
      checkStatusOnly();
    }, 3000);

    return () => clearInterval(pollInterval);
  }, [id, token, hasHydrated, order?.status]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      const res = await api.get(`/orders/${id}`);
      
      // Keamanan sisi client: pastikan user adalah pemilik
      // Gunakan setTimeout kecil untuk memastikan state 'user' sudah siap
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
        toast.error('Gagal memuat pesanan');
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
      // HANYA kurangi countdown jika tab sedang dilihat (tidak di-minimize/pindah tab)
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
    toast((t) => (
      <div className="flex flex-col gap-3 min-w-[240px]">
        <span className="font-bold text-sm">Batalkan pesanan ini?</span>
        <p className="text-[10px] text-gray-500 leading-tight">Tindakan ini tidak dapat dibatalkan dan stok akan dikembalikan.</p>
        <div className="flex gap-2 justify-end mt-2">
          <button onClick={() => toast.dismiss(t.id)} className="px-4 py-2 bg-gray-50 hover:bg-gray-100 rounded-xl text-xs font-bold transition-colors">Batal</button>
          <button 
            onClick={async () => {
              toast.dismiss(t.id);
              try {
                await api.put(`/orders/${id}/cancel`, {});
                toast.success('Pesanan dibatalkan');
                fetchOrder();
              } catch (error) { toast.error('Gagal membatalkan'); }
            }} 
            className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-xl text-xs font-bold transition-colors shadow-lg shadow-red-200"
          >
            Ya, Batalkan
          </button>
        </div>
      </div>
    ), { duration: 6000 });
  };

  if (!hasHydrated || loading) return <div className="min-h-screen bg-gray-50 flex items-center justify-center font-bold">Memuat data...</div>;
  if (!order) return <div className="min-h-screen bg-gray-50 pt-24 text-center font-bold">Pesanan tidak ditemukan</div>;

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />

      {/* SUCCESS OVERLAY */}
      {successRedirect && (
        <div className="fixed inset-0 z-[100] bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-8 max-w-sm w-full text-center shadow-2xl animate-in zoom-in duration-300">
            <div className="w-20 h-20 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
              <CheckCircle2 size={48} />
            </div>
            <h2 className="text-2xl font-black mb-2">Pembayaran Berhasil!</h2>
            <p className="text-gray-500 text-sm mb-8">Terima kasih atas pembayaran Anda. Pesanan akan segera diproses.</p>
            <div className="bg-gray-50 rounded-2xl py-4 flex flex-col items-center">
              <Loader2 className="animate-spin text-blue-600 mb-2" size={24} />
              <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">
                Mengalihkan dalam {countdown} detik...
              </p>
            </div>
          </div>
        </div>
      )}

      <main className="max-w-3xl mx-auto px-4 pt-24">
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => router.push('/orders')} className="p-2 bg-white rounded-full border border-gray-200 hover:bg-gray-100">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-xl font-bold">Rincian Pesanan</h1>
            <p className="text-sm text-gray-500">Invoice: {order.invoiceNumber}</p>
          </div>
        </div>

        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center">
              <span className="text-sm text-gray-500 mr-2">Status Pesanan</span>
              {order.status === 'PENDING' && <CountdownTimer dateString={order.createdAt} expiryTime={order.paymentDetails?.expiry_time} />}
            </div>
            <span className={`px-3 py-1 rounded-full text-xs font-bold 
              ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 
                order.status === 'PENDING' ? 'bg-orange-100 text-orange-700' : 
                'bg-gray-100 text-gray-700'}`}>
              {order.status}
            </span>
          </div>

          {order.status === "PENDING" && order.paymentDetails && (
            <div className="mb-6 bg-gray-50 p-6 rounded-2xl border border-dashed border-gray-200">
              <h3 className="text-sm font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <CreditCard size={16} /> Instruksi Pembayaran
              </h3>
              
              {order.paymentDetails.va_number && (
                <div className="space-y-4">
                  <div>
                    <p className="text-xs text-gray-500 mb-1">Nomor Virtual Account ({order.paymentDetails.bank?.toUpperCase()})</p>
                    <div className="flex items-center justify-between bg-white p-4 rounded-xl border border-gray-100">
                      <span className="text-xl font-mono font-bold tracking-wider">{order.paymentDetails.va_number}</span>
                      <button onClick={() => {navigator.clipboard.writeText(order.paymentDetails?.va_number || ""); toast.success("Salin!")}} className="p-2 hover:bg-gray-50 rounded-lg text-blue-600"><Copy size={18} /></button>
                    </div>
                  </div>
                </div>
              )}

              {order.paymentDetails.qr_url && (
                <div className="flex flex-col items-center">
                  {/* Sembunyikan QR jika GoPay (karena sudah ada Deeplink), kecuali jika tidak ada Deeplink */}
                  {!(order.paymentType === 'gopay' && order.paymentDetails.deeplink) && (
                    <>
                      <p className="text-xs text-gray-500 mb-4 text-center">Scan QR Code di bawah untuk membayar</p>
                      <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100">
                        <img src={order.paymentDetails.qr_url} alt="QR Code" className="w-48 h-48" />
                      </div>
                    </>
                  )}
                  
                  {order.paymentDetails.deeplink && (
                    <div className="mt-4 flex flex-col items-center gap-2">
                      <a 
                        href={order.paymentDetails.deeplink} 
                        className={`px-8 py-3 text-white rounded-xl font-bold shadow-lg transition-transform active:scale-95 ${
                          order.paymentType === 'gopay' ? 'bg-[#00AABB] shadow-[#00AABB]/20' : 
                          order.paymentType === 'shopeepay' ? 'bg-[#EE4D2D] shadow-[#EE4D2D]/20' :
                          'bg-[#118EEA] shadow-[#118EEA]/20'
                        }`}
                      >
                        Buka Aplikasi {order.paymentType === 'gopay' ? 'Gojek' : order.paymentType === 'shopeepay' ? 'Shopee' : 'DANA'}
                      </a>
                      <p className="text-[10px] text-gray-400 mt-2">Klik tombol di atas jika Anda membayar melalui HP</p>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
          
          {order.status === 'PENDING' && (
            <button onClick={handleCancel} className="w-full bg-white border border-red-200 text-red-600 py-3 rounded-lg font-bold hover:bg-red-50 transition-colors">
              Batalkan Pesanan
            </button>
          )}
        </div>

        {/* Product List */}
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <h3 className="font-bold mb-4">Barang yang Dibeli</h3>
          <div className="space-y-4">
            {order.items.map((item, idx) => (
              <div key={idx} className="flex gap-4 border-b border-gray-50 last:border-0 pb-4 last:pb-0">
                <img src={item.product.images[0] || 'https://placehold.co/100'} className="w-16 h-16 rounded-lg bg-gray-100 object-cover" />
                <div className="flex-1">
                  <h4 className="font-medium text-sm line-clamp-2">{item.product.name}</h4>
                  <p className="text-xs text-gray-500 mt-1">{item.quantity} x Rp {item.price.toLocaleString('id-ID')}</p>
                </div>
                <p className="font-bold text-sm">Rp {(item.price * item.quantity).toLocaleString('id-ID')}</p>
              </div>
            ))}
          </div>
          <div className="mt-6 pt-4 border-t border-gray-100 flex justify-between items-center font-bold">
            <span className="text-gray-500">Total</span>
            <span className="text-xl">Rp {order.totalAmount.toLocaleString('id-ID')}</span>
          </div>
        </div>

        {order.timeline && order.timeline.length > 0 && (
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <h3 className="font-bold mb-6 flex items-center gap-2"><Activity size={20} className="text-blue-600" /> Timeline</h3>
            <div className="relative pl-4 border-l-2 border-gray-100 space-y-8">
              {order.timeline.map((step, idx) => (
                <div key={idx} className="relative">
                  <div className="absolute -left-[21px] top-0 w-4 h-4 bg-blue-600 rounded-full border-4 border-white shadow-sm"></div>
                  <h4 className="font-bold text-sm">{step.title}</h4>
                  <p className="text-[10px] text-gray-400">{new Date(step.timestamp).toLocaleString()}</p>
                  <p className="text-sm text-gray-600 mt-2 bg-gray-50 p-3 rounded-lg border border-gray-100">{step.description}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
