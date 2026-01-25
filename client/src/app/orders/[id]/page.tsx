'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import { ArrowLeft, Copy, Download, AlertCircle, CheckCircle, XCircle, CreditCard, RefreshCcw } from 'lucide-react';
import toast from 'react-hot-toast';

interface OrderDetail {
  id: string;
  invoiceNumber: string;
  totalAmount: number;
  status: string;
  snapToken?: string;
  deliveryInfo?: string;
  refundReason?: string;
  refundAccount?: string; // Added this line
  refundStatus?: string; 
  createdAt: string;
  items: {
    product: { name: string; images: string[]; type: string };
    quantity: number;
    price: number;
  }[];
}

export default function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [order, setOrder] = useState<OrderDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const { token } = useAuthStore();
  const router = useRouter();

  // Refund State
  const [refundReason, setRefundReason] = useState('');
  const [refundAccount, setRefundAccount] = useState('');
  const [showRefundForm, setShowRefundForm] = useState(false);

  useEffect(() => {
    // Load Midtrans Snap script
    const script = document.createElement('script');
    script.src = "https://app.sandbox.midtrans.com/snap/snap.js"; // Change to production URL if needed
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);

    if (token) fetchOrder();
  }, [id, token]);

  const fetchOrder = async () => {
    try {
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/orders/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setOrder(res.data);
    } catch (error) {
      toast.error('Gagal memuat pesanan');
    } finally {
      setLoading(false);
    }
  };

  const handlePay = async () => {
    if (!window.snap) return toast.error("Sistem pembayaran sedang memuat...");

    try {
      // Minta token baru (fresh) agar tidak expired
      const res = await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/orders/${id}/pay`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      const { snapToken } = res.data;

      window.snap.pay(snapToken, {
        onSuccess: () => { 
          toast.success('Pembayaran Berhasil!'); 
          window.location.reload(); 
        },
        onPending: () => { 
          toast('Menunggu pembayaran...'); 
          window.location.reload(); 
        },
        onError: () => { toast.error('Pembayaran Gagal'); },
        onClose: () => { toast('Pembayaran belum selesai'); }
      });
    } catch (error) {
      toast.error('Gagal memuat pembayaran');
    }
  };

  const handleCancel = async () => {
    toast((t) => (
      <div className="flex flex-col gap-3 min-w-[250px] text-center">
        <div className="mx-auto bg-red-100 p-2 rounded-full text-red-600">
          <AlertCircle size={24}/>
        </div>
        <span className="font-bold">Yakin ingin membatalkan pesanan?</span>
        <p className="text-xs text-gray-500">Tindakan ini tidak dapat dibatalkan.</p>
        <div className="flex gap-2 justify-center mt-2">
          <button onClick={() => toast.dismiss(t.id)} className="px-4 py-2 bg-gray-100 rounded-lg text-xs font-bold hover:bg-gray-200 w-full">Kembali</button>
          <button onClick={() => {
            confirmCancel();
            toast.dismiss(t.id);
          }} className="px-4 py-2 bg-red-600 text-white rounded-lg text-xs font-bold hover:bg-red-700 w-full">Batalkan</button>
        </div>
      </div>
    ), { 
      duration: Infinity, // Biar gak hilang sendiri sebelum diklik
      position: 'top-center',
      style: {
        background: '#fff',
        padding: '24px',
        borderRadius: '16px',
        boxShadow: '0 10px 30px rgba(0,0,0,0.1)'
      }
    });
  };

  const confirmCancel = async () => {
    try {
      await axios.put(`${process.env.NEXT_PUBLIC_API_URL}/orders/${id}/cancel`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      });
      toast.success('Pesanan dibatalkan');
      fetchOrder();
    } catch (error) {
      toast.error('Gagal membatalkan pesanan');
    }
  };

  const handleSubmitRefund = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/orders/${id}/refund`, {
        reason: refundReason,
        account: refundAccount
      }, {
        headers: { Authorization: `Bearer ${token}` }
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
          <button onClick={() => router.back()} className="p-2 bg-white rounded-full border border-gray-200 hover:bg-gray-100">
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
            <span className="text-sm text-gray-500">Status Pesanan</span>
            <span className={`px-3 py-1 rounded-full text-xs font-bold 
              ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 
                order.status === 'PENDING' ? 'bg-orange-100 text-orange-700' : 
                'bg-gray-100 text-gray-700'}`}>
              {order.status}
            </span>
          </div>
          
          {/* Action Buttons based on Status */}
          {order.status === 'PENDING' && (
            <div className="flex gap-3">
              <button onClick={handlePay} className="flex-1 bg-black text-white py-3 rounded-lg font-bold hover:bg-gray-800 transition-colors">
                Bayar Sekarang
              </button>
              <button onClick={handleCancel} className="flex-1 bg-white border border-red-200 text-red-600 py-3 rounded-lg font-bold hover:bg-red-50 transition-colors">
                Batalkan
              </button>
            </div>
          )}

          {/* Refund Button if Paid */}
          {order.status === 'PAID' && !showRefundForm && !order.refundReason && (
            <button onClick={() => setShowRefundForm(true)} className="w-full mt-4 text-sm text-gray-500 underline hover:text-red-500">
              Ajukan Pengembalian Dana (Refund)
            </button>
          )}
        </div>

        {/* Delivery Info (Digital Product) */}
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

        {/* Refund Status Info */}
        {order.refundReason && (
          <div className="bg-yellow-50 rounded-xl p-6 border border-yellow-100 mb-6">
            <h3 className="font-bold text-yellow-800 mb-2 flex items-center gap-2">
              <RefreshCcw size={18} /> Status Refund
            </h3>
            <p className="text-sm text-yellow-700 mb-2">Anda telah mengajukan refund.</p>
            <div className="bg-white/50 p-3 rounded text-xs text-gray-600">
              <strong>Alasan:</strong> {order.refundReason}<br/>
              <strong>Rekening:</strong> {order.refundAccount}
            </div>
            {order.status === 'REFUND_APPROVED' && (
              <p className="mt-3 text-sm font-bold text-green-600">Refund disetujui. Dana sedang diproses.</p>
            )}
            {order.status === 'REFUND_REJECTED' && (
              <p className="mt-3 text-sm font-bold text-red-600">Refund ditolak oleh Admin.</p>
            )}
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
