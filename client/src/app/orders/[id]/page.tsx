'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { ArrowLeft, Copy, Download, AlertCircle, CheckCircle, XCircle, CreditCard, RefreshCcw, Activity } from 'lucide-react';
import toast from 'react-hot-toast';

interface OrderDetail {
  id: string;
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
  refundStatus?: string; 
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

// Helper Countdown
const CountdownTimer = ({ dateString, expiryTime }: { dateString: string; expiryTime?: string }) => {
  const [timeLeft, setTimeLeft] = useState('');
  useEffect(() => {
    // If CORE and has expiry_time, use it. Otherwise use 24h from createdAt.
    const target = expiryTime 
      ? new Date(expiryTime).getTime()
      : new Date(dateString).getTime() + 24 * 60 * 60 * 1000;

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
  const { user, token } = useAuthStore();
  const router = useRouter();

  // Refund State
  const [refundReason, setRefundReason] = useState('');
  const [refundAccount, setRefundAccount] = useState('');
  const [showRefundForm, setShowRefundForm] = useState(false);

  useEffect(() => {
    if (token) fetchOrder();
    else router.push('/login');
  }, [id, token]);

  const fetchOrder = async () => {
    try {
      const res = await api.get(`/orders/${id}`);
      
      // Client-side Security: Double check owner
      if (user && user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN' && res.data.userId !== user.id) {
        toast.error('Anda tidak memiliki akses ke pesanan ini');
        router.push('/orders');
        return;
      }

      setOrder(res.data);
    } catch (error: any) {
      if (error.response?.status === 403) {
        toast.error('Akses ditolak');
        router.push('/orders');
      } else {
        toast.error('Gagal memuat pesanan');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async () => {
    if (!confirm('Yakin batalkan pesanan?')) return;
    try {
      await api.put(`/orders/${id}/cancel`, {});
      toast.success('Pesanan dibatalkan');
      fetchOrder();
    } catch (error) {
      toast.error('Gagal membatalkan pesanan');
    }
  };

  const handleSubmitRefund = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post(`/orders/${id}/refund`, {
        reason: refundReason,
        account: refundAccount
      });
      toast.success('Pengajuan refund dikirim');
      setShowRefundForm(false);
      fetchOrder();
    } catch (error) {
      toast.error('Gagal mengajukan refund');
    }
  };

  if (loading) return <div className="min-h-screen bg-gray-50 pt-24 text-center">Memuat...</div>;
  if (!order) return <div className="min-h-screen bg-gray-50 pt-24 text-center">Pesanan tidak ditemukan</div>;

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />
      <main className="max-w-3xl mx-auto px-4 pt-24">
        
        {/* Header */}
        <div className="flex items-center gap-4 mb-6">
          <button onClick={() => router.push('/orders')} className="p-2 bg-white rounded-full border border-gray-200 hover:bg-gray-100">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-xl font-bold">Rincian Pesanan</h1>
            <p className="text-sm text-gray-500">Invoice: {order.invoiceNumber}</p>
          </div>
        </div>

        {/* Status Card */}
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

          {/* Payment Details (CORE API) */}
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
                      <button 
                        onClick={() => {navigator.clipboard.writeText(order.paymentDetails?.va_number || ""); toast.success("Salin!")}}
                        className="p-2 hover:bg-gray-50 rounded-lg text-blue-600"
                      >
                        <Copy size={18} />
                      </button>
                    </div>
                  </div>
                  <div className="text-[11px] text-gray-400 bg-white p-3 rounded-lg border border-gray-100">
                    <p className="font-bold mb-1">Cara Bayar:</p>
                    <ol className="list-decimal list-inside space-y-0.5">
                      <li>Buka Aplikasi Mobile Banking / ATM Anda</li>
                      <li>Pilih menu Transfer / Virtual Account</li>
                      <li>Masukkan nomor di atas</li>
                      <li>Konfirmasi nominal dan bayar</li>
                    </ol>
                  </div>
                </div>
              )}

              {order.paymentDetails.qr_url && (
                <div className="flex flex-col items-center">
                  <p className="text-xs text-gray-500 mb-4 text-center">Scan QR Code di bawah untuk membayar</p>
                  <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100">
                    <img src={order.paymentDetails.qr_url} alt="QR Code" className="w-48 h-48" />
                  </div>
                  {order.paymentDetails.deeplink && (
                    <a 
                      href={order.paymentDetails.deeplink} 
                      className="mt-4 px-6 py-2 bg-[#00AABB] text-white rounded-xl text-sm font-bold shadow-lg shadow-[#00AABB]/20"
                    >
                      Buka di Aplikasi Gojek
                    </a>
                  )}
                </div>
              )}

              {order.paymentDetails.bill_key && (
                <div className="space-y-4">
                   <div>
                    <p className="text-xs text-gray-500 mb-1">Biller Code</p>
                    <div className="bg-white p-3 rounded-xl border border-gray-100 font-mono font-bold">{order.paymentDetails.biller_code}</div>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500 mb-1">Bill Key</p>
                    <div className="flex items-center justify-between bg-white p-4 rounded-xl border border-gray-100">
                      <span className="text-xl font-mono font-bold tracking-wider">{order.paymentDetails.bill_key}</span>
                      <button 
                        onClick={() => {navigator.clipboard.writeText(order.paymentDetails?.bill_key || ""); toast.success("Salin!")}}
                        className="p-2 hover:bg-gray-50 rounded-lg text-blue-600"
                      >
                        <Copy size={18} />
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
          
          {order.status === 'PENDING' && (
            <div className="flex gap-3">
              <button onClick={handleCancel} className="w-full bg-white border border-red-200 text-red-600 py-3 rounded-lg font-bold hover:bg-red-50 transition-colors">
                Batalkan Pesanan
              </button>
            </div>
          )}

          {order.status === 'PAID' && !showRefundForm && !order.refundReason && (
            <button onClick={() => setShowRefundForm(true)} className="w-full mt-4 text-sm text-gray-500 underline hover:text-red-500">
              Ajukan Pengembalian Dana (Refund)
            </button>
          )}
        </div>

        {/* PROGRESS TRACKER (TIMELINE) */}
        {order.timeline && order.timeline.length > 0 && (
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
            <h3 className="font-bold mb-6 flex items-center gap-2">
              <Activity size={20} className="text-accent" /> Timeline Pengerjaan
            </h3>
            <div className="relative pl-4 border-l-2 border-gray-100 space-y-8">
              {order.timeline.map((step, idx) => (
                <div key={idx} className="relative">
                  <div className="absolute -left-[21px] top-0 w-4 h-4 bg-accent rounded-full border-4 border-white shadow-sm"></div>
                  <h4 className="font-bold text-sm">{step.title}</h4>
                  <p className="text-xs text-gray-500 mt-1">{new Date(step.timestamp).toLocaleString()}</p>
                  {step.description && (
                    <p className="text-sm text-gray-600 mt-2 bg-gray-50 p-3 rounded-lg border border-gray-100">
                      {step.description}
                    </p>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Delivery Info */}
        {(order.status === 'PAID' || order.status === 'COMPLETED' || order.status === 'SHIPPED') && (
          <div className="bg-blue-50 rounded-xl p-6 border border-blue-100 mb-6">
            <h3 className="font-bold text-blue-800 mb-2 flex items-center gap-2">
              <Download size={18} /> Informasi Pengiriman / Akses
            </h3>
            {order.deliveryInfo ? (
              <div className="bg-white p-4 rounded-lg border border-blue-100 text-sm whitespace-pre-wrap font-mono">
                {order.deliveryInfo}
              </div>
            ) : (
              <p className="text-sm text-blue-600">
                Admin sedang menyiapkan file/akses untuk Anda. Harap cek secara berkala.
              </p>
            )}
          </div>
        )}

        {/* Refund Form */}
        {showRefundForm && (
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
            <h3 className="font-bold mb-4">Formulir Refund</h3>
            <form onSubmit={handleSubmitRefund} className="space-y-4">
              <div>
                <label className="text-xs font-bold text-gray-500 uppercase">Alasan Refund</label>
                <textarea 
                  required
                  value={refundReason}
                  onChange={(e) => setRefundReason(e.target.value)}
                  className="w-full p-3 border border-gray-200 rounded-lg text-sm mt-1 focus:outline-none focus:border-black"
                  placeholder="Jelaskan kenapa Anda mengajukan refund..."
                />
              </div>
              <div>
                <label className="text-xs font-bold text-gray-500 uppercase">Rekening Tujuan</label>
                <input 
                  required
                  type="text"
                  value={refundAccount}
                  onChange={(e) => setRefundAccount(e.target.value)}
                  className="w-full p-3 border border-gray-200 rounded-lg text-sm mt-1 focus:outline-none focus:border-black"
                  placeholder="Nama Bank - No Rekening - Atas Nama"
                />
              </div>
              <div className="flex justify-end gap-3">
                <button type="button" onClick={() => setShowRefundForm(false)} className="text-sm text-gray-500 hover:text-black">Batal</button>
                <button type="submit" className="bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-bold hover:bg-red-700">Kirim Pengajuan</button>
              </div>
            </form>
          </div>
        )}

        {/* Product List */}
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
          <h3 className="font-bold mb-4">Barang yang Dibeli</h3>
          <div className="space-y-4">
            {order.items.map((item, idx) => (
              <div key={idx} className="flex gap-4 border-b border-gray-50 last:border-0 pb-4 last:pb-0">
                <img src={item.product.images[0] || 'https://placehold.co/100'} className="w-16 h-16 rounded-lg bg-gray-100 object-cover" />
                <div className="flex-1">
                  <h4 className="font-medium text-sm line-clamp-2">{item.product.name}</h4>
                  <p className="text-xs text-gray-500 mt-1">{item.quantity} x Rp {item.price.toLocaleString('id-ID')}</p>
                </div>
                <div className="text-right">
                  <p className="font-bold text-sm">Rp {(item.price * item.quantity).toLocaleString('id-ID')}</p>
                </div>
              </div>
            ))}
          </div>
          <div className="mt-6 pt-4 border-t border-gray-100 flex justify-between items-center">
            <span className="text-gray-500 text-sm">Total Pembayaran</span>
            <span className="text-xl font-bold">Rp {order.totalAmount.toLocaleString('id-ID')}</span>
          </div>
        </div>

      </main>
    </div>
  );
}