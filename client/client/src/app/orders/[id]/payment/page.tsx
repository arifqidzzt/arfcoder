'use client';

import { useState, useEffect, use } from 'react';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { useRouter } from 'next/navigation';
import { 
  CreditCard, 
  Clock, 
  Copy, 
  CheckCircle2, 
  AlertCircle, 
  ArrowLeft,
  RefreshCcw,
  ExternalLink
} from 'lucide-react';
import Navbar from '@/components/Navbar';

export default function PaymentPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const router = useRouter();
  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [timeLeft, setTimeLeft] = useState<string>('');
  const [checking, setChecking] = useState(false);

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    try {
      const res = await api.get(`/orders/${id}`);
      setOrder(res.data);
      if (res.data.status === 'PAID') {
        router.push(`/orders/${id}`);
      }
    } catch (error) {
      toast.error('Gagal mengambil data pesanan');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!order?.paymentExpiredAt) return;

    const timer = setInterval(() => {
      const now = new Date().getTime();
      const end = new Date(order.paymentExpiredAt).getTime();
      const diff = end - now;

      if (diff <= 0) {
        setTimeLeft('EXPIRED');
        clearInterval(timer);
      } else {
        const hours = Math.floor(diff / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);
        setTimeLeft(`${hours}:${minutes}:${seconds < 10 ? '0' : ''}${seconds}`);
      }
    }, 1000);

    return () => clearInterval(timer);
  }, [order]);

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text);
    toast.success('Berhasil disalin!');
  };

  const checkStatus = async () => {
    setChecking(true);
    try {
      const res = await api.get(`/orders/${id}/payment-status`);
      if (res.data.status === 'PAID' || res.data.transactionStatus === 'settlement' || res.data.transactionStatus === 'capture') {
        toast.success('Pembayaran Berhasil!');
        router.push(`/orders/${id}`);
      } else {
        toast('Pembayaran belum diterima');
      }
    } catch (error) {
      toast.error('Gagal mengecek status');
    } finally {
      setChecking(false);
    }
  };

  const handleRegenerate = async () => {
    setLoading(true);
    try {
      await api.post(`/orders/${id}/regenerate-payment`);
      toast.success('Pembayaran diperbarui');
      fetchOrder();
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Gagal memperbarui pembayaran');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  if (!order) return <div className="min-h-screen flex items-center justify-center">Order tidak ditemukan</div>;

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <main className="max-w-2xl mx-auto px-4 py-24 w-full">
        <button 
          onClick={() => router.push('/orders')}
          className="flex items-center gap-2 text-gray-500 mb-6 hover:text-black transition-colors"
        >
          <ArrowLeft size={18} /> Kembali ke Pesanan
        </button>

        <div className="bg-white rounded-3xl shadow-xl overflow-hidden border border-gray-100">
          {/* Header */}
          <div className="bg-black p-8 text-white">
            <div className="flex justify-between items-center mb-4">
              <span className="text-gray-400 text-sm font-bold uppercase tracking-widest">Selesaikan Pembayaran</span>
              <div className="flex items-center gap-2 bg-white/10 px-3 py-1 rounded-full">
                <Clock size={14} className="text-accent" />
                <span className="text-sm font-mono font-bold text-accent">{timeLeft}</span>
              </div>
            </div>
            <h1 className="text-3xl font-black">Rp {order.totalAmount.toLocaleString()}</h1>
            <p className="text-gray-400 text-xs mt-2">Order ID: {order.id}</p>
          </div>

          <div className="p-8 space-y-8">
            {/* Payment Info */}
            <div>
              <label className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 block">Metode Pembayaran</label>
              <div className="flex items-center gap-4 p-4 bg-gray-50 rounded-2xl border border-gray-100">
                <div className="w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-sm border border-gray-100 font-bold text-xs uppercase">
                  {order.coreApiBankCode || 'PAY'}
                </div>
                <div>
                  <h3 className="font-bold">{order.coreApiPaymentMethod?.toUpperCase()}</h3>
                  <p className="text-xs text-gray-500">Bayar sebelum {new Date(order.paymentExpiredAt).toLocaleString()}</p>
                </div>
              </div>
            </div>

            {/* VA Number or QRIS */}
            {order.coreApiVaNumber && (
              <div>
                <label className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 block">Nomor Virtual Account</label>
                <div className="flex items-center justify-between p-6 bg-gray-50 rounded-2xl border-2 border-dashed border-gray-200">
                  <span className="text-2xl font-mono font-black tracking-wider">{order.coreApiVaNumber}</span>
                  <button 
                    onClick={() => handleCopy(order.coreApiVaNumber)}
                    className="p-3 bg-white rounded-xl shadow-sm hover:bg-gray-100 transition-all active:scale-90"
                  >
                    <Copy size={20} />
                  </button>
                </div>
              </div>
            )}

            {order.coreApiQrisUrl && (
              <div className="text-center">
                <label className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 block">Scan Kode QRIS</label>
                <div className="inline-block p-4 bg-white border-2 border-gray-100 rounded-3xl shadow-sm">
                  <img src={order.coreApiQrisUrl} alt="QRIS" className="w-64 h-64 mx-auto" />
                </div>
                <p className="text-xs text-gray-500 mt-4">Gunakan aplikasi e-wallet atau m-banking favorit Anda.</p>
              </div>
            )}

            {order.coreApiDeeplinkUrl && (
              <div className="text-center">
                <a 
                  href={order.coreApiDeeplinkUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-full py-4 bg-blue-600 text-white rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-blue-700 transition-all shadow-lg shadow-blue-200"
                >
                  Buka Aplikasi Pembayaran <ExternalLink size={18} />
                </a>
              </div>
            )}

            {/* Instruction */}
            <div className="bg-blue-50 p-6 rounded-2xl space-y-3 border border-blue-100">
              <div className="flex items-center gap-2 text-blue-700">
                <AlertCircle size={18} />
                <h4 className="font-bold text-sm">Petunjuk Pembayaran</h4>
              </div>
              <ul className="text-xs text-blue-600 space-y-2 list-disc ml-4 leading-relaxed">
                <li>Buka aplikasi perbankan atau e-wallet Anda.</li>
                <li>Pilih menu Transfer atau Bayar.</li>
                <li>Masukkan nomor Virtual Account atau scan kode QR di atas.</li>
                <li>Pastikan nominal yang muncul sama dengan total tagihan.</li>
                <li>Simpan bukti pembayaran Anda.</li>
              </ul>
            </div>

            {/* Actions */}
            <div className="pt-8 border-t border-gray-100 space-y-4">
              <button 
                onClick={checkStatus}
                disabled={checking || timeLeft === 'EXPIRED'}
                className="w-full py-4 bg-black text-white rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-gray-800 transition-all disabled:bg-gray-300 shadow-xl shadow-black/10"
              >
                <RefreshCcw size={18} className={checking ? 'animate-spin' : ''} />
                {checking ? 'Mengecek...' : 'Saya Sudah Bayar'}
              </button>

              {timeLeft === 'EXPIRED' && (
                <div className="p-6 bg-red-50 rounded-2xl text-center border border-red-100">
                  <p className="text-red-600 font-bold text-sm mb-4">Waktu pembayaran telah habis.</p>
                  <button 
                    onClick={handleRegenerate}
                    className="px-6 py-2 bg-red-600 text-white rounded-xl font-bold text-sm hover:bg-red-700 transition-all"
                  >
                    Perbarui Pembayaran
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
