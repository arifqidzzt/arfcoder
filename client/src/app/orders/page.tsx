'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { Package, ChevronRight, CreditCard, AlertCircle } from 'lucide-react';
import Link from 'next/link';
import AuthGuard from '@/components/AuthGuard';

declare global {
  interface Window {
    snap: any;
  }
}

interface Order {
  id: string;
  invoiceNumber: string;
  totalAmount: number;
  status: string;
  createdAt: string;
  snapToken?: string;
  items: { product: { name: string; images: string[] } }[];
}

// Helper component for Countdown
const CountdownTimer = ({ dateString }: { dateString: string }) => {
  const [timeLeft, setTimeLeft] = useState('');

  useEffect(() => {
    const target = new Date(dateString).getTime() + 24 * 60 * 60 * 1000;
    const interval = setInterval(() => {
      const now = new Date().getTime();
      const distance = target - now;
      if (distance < 0) {
        setTimeLeft('Expired');
        clearInterval(interval);
      } else {
        const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        setTimeLeft(`${hours}j ${minutes}m`);
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [dateString]);

  return <span className="text-red-500 font-bold text-[10px]">{timeLeft}</span>;
};

export default function MyOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('ALL');
  const { token } = useAuthStore();

  useEffect(() => {
    const script = document.createElement('script');
    script.src = "https://app.sandbox.midtrans.com/snap/snap.js";
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);
    
    const fetchOrders = async () => {
      try {
        const res = await api.get('/orders/my');
        setOrders(res.data);
      } catch (error) { console.error(error); } finally { setLoading(false); }
    };
    if(token) fetchOrders();
  }, [token]);

  const handlePay = (snapToken?: string) => {
    if (snapToken && window.snap) {
      window.snap.pay(snapToken, {
        onSuccess: () => window.location.reload(),
        onPending: () => window.location.reload(),
        onError: () => alert('Pembayaran gagal')
      });
    } else {
      alert('Token pembayaran tidak valid');
    }
  };

  const filteredOrders = orders.filter(o => {
    if (activeTab === 'ALL') return true;
    if (activeTab === 'UNPAID') return o.status === 'PENDING';
    if (activeTab === 'PROCESS') return o.status === 'PAID' || o.status === 'PROCESSING' || o.status === 'SHIPPED';
    if (activeTab === 'DONE') return o.status === 'COMPLETED';
    return false;
  });

  const tabs = [
    { id: 'ALL', label: 'Semua' },
    { id: 'UNPAID', label: 'Belum Bayar' },
    { id: 'PROCESS', label: 'Diproses' },
    { id: 'DONE', label: 'Selesai' },
  ];

  return (
    <AuthGuard>
      <div className="min-h-screen bg-white">
        <Navbar />
        <main className="max-w-4xl mx-auto px-4 sm:px-8 py-12 pt-24">
          <h1 className="text-3xl font-bold mb-8">Pesanan Saya</h1>

          <div className="flex border-b border-gray-100 mb-8 overflow-x-auto bg-white rounded-t-xl px-2">
            {tabs.map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-6 py-4 text-sm font-bold whitespace-nowrap transition-colors border-b-2 
                  ${activeTab === tab.id ? 'border-black text-black' : 'border-transparent text-gray-400 hover:text-gray-600'}`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {loading ? (
            <div className="text-center py-12 text-gray-400">Memuat...</div>
          ) : filteredOrders.length === 0 ? (
            <div className="text-center py-20 border border-dashed border-gray-200 rounded-xl bg-white">
              <Package className="mx-auto text-gray-200 mb-4" size={48} />
              <p className="text-gray-500 font-medium">Tidak ada pesanan di kategori ini.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredOrders.map((order) => (
                <div key={order.id} className="block border border-gray-100 rounded-2xl p-6 hover:shadow-md transition-all bg-white relative">
                  <div className="flex justify-between items-start mb-6">
                    <div className="space-y-2">
                      <span className={`text-[10px] font-black px-2 py-1 rounded-full uppercase tracking-wider
                        ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 
                          order.status === 'PENDING' ? 'bg-orange-100 text-orange-700' : 'bg-gray-100 text-gray-600'}`}>
                        {order.status}
                      </span>
                      
                      {order.status === 'PENDING' && (
                        <div className="flex items-center gap-2 bg-red-50 text-red-600 px-2 py-1 rounded-lg border border-red-100">
                          <AlertCircle size={12}/>
                          <span className="text-[10px] font-bold">Batas Bayar:</span>
                          <CountdownTimer dateString={order.createdAt} />
                        </div>
                      )}
                    </div>
                    
                    {order.status === 'PENDING' ? (
                      <Link 
                        href={`/orders/${order.id}`}
                        className="bg-black text-white px-4 py-2 rounded-xl text-xs font-bold hover:bg-gray-800 flex items-center gap-2 transition-all shadow-lg shadow-black/10"
                      >
                        <CreditCard size={14}/> Lanjut Bayar
                      </Link>
                    ) : (
                      <Link href={`/orders/${order.id}`} className="text-xs font-bold text-accent hover:underline flex items-center gap-1">
                        Lihat Detail <ChevronRight size={14}/>
                      </Link>
                    )}
                  </div>
                  
                  <Link href={`/orders/${order.id}`} className="flex gap-4 items-center group">
                    <div className="w-16 h-16 rounded-xl bg-gray-50 overflow-hidden border border-gray-100 flex-shrink-0">
                      <img src={order.items[0]?.product.images[0] || 'https://placehold.co/100'} className="w-full h-full object-cover" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-bold text-gray-800 line-clamp-1 group-hover:text-accent transition-colors">
                        {order.items[0]?.product.name} {order.items.length > 1 && `+ ${order.items.length - 1} item lainnya`}
                      </p>
                      <p className="text-xs text-gray-400 mt-1">{new Date(order.createdAt).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}</p>
                      <p className="text-sm font-black mt-2">Rp {order.totalAmount.toLocaleString('id-ID')}</p>
                    </div>
                  </Link>
                </div>
              ))}
            </div>
          )}
        </main>
      </div>
    </AuthGuard>
  );
}
