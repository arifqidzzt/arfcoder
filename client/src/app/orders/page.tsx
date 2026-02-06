'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import api from '@/lib/api';
import { Package, ChevronRight, CreditCard, AlertCircle } from 'lucide-react';
import Link from 'next/link';
import AuthGuard from '@/components/AuthGuard';
import { useTranslation } from '@/lib/i18n';

interface Order {
  id: string;
  invoiceNumber: string;
  totalAmount: number;
  status: string;
  createdAt: string;
  items: { product: { name: string; images: string[] } }[];
}

const CountdownTimer = ({ dateString }: { dateString: string }) => {
  const [timeLeft, setTimeLeft] = useState('');
  useEffect(() => {
    const target = new Date(dateString).getTime() + 24 * 60 * 60 * 1000;
    const interval = setInterval(() => {
      const now = new Date().getTime();
      const distance = target - now;
      if (distance < 0) { setTimeLeft('Expired'); clearInterval(interval); }
      else {
        const h = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const m = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        setTimeLeft(`${h}j ${m}m`);
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [dateString]);
  return <span className="text-red-500 font-bold text-[10px]">{timeLeft}</span>;
};

export default function MyOrdersPage() {
  const { t } = useTranslation();
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('ALL');
  const { token } = useAuthStore();

  useEffect(() => {
    if(token) fetchOrders();
  }, [token]);

  const fetchOrders = async () => {
    try {
      const res = await api.get('/orders/my');
      setOrders(res.data);
    } catch (error) { console.error(error); } finally { setLoading(false); }
  };

  const filteredOrders = orders.filter(o => {
    if (activeTab === 'ALL') return true;
    if (activeTab === 'UNPAID') return o.status === 'PENDING';
    if (activeTab === 'PROCESS') return o.status === 'PAID' || o.status === 'PROCESSING' || o.status === 'SHIPPED';
    if (activeTab === 'DONE') return o.status === 'COMPLETED';
    return false;
  });

  return (
    <AuthGuard>
      <div className="min-h-screen bg-white">
        <Navbar />
        <main className="max-w-4xl mx-auto px-4 py-24">
          <h1 className="text-3xl font-bold mb-8">{t('orders.list_title')}</h1>

          <div className="flex border-b border-gray-100 mb-8 overflow-x-auto">
            {['ALL', 'UNPAID', 'PROCESS', 'DONE'].map(tabId => (
              <button
                key={tabId}
                onClick={() => setActiveTab(tabId)}
                className={`px-6 py-4 text-sm font-bold whitespace-nowrap border-b-2 transition-all 
                  ${activeTab === tabId ? 'border-black text-black' : 'border-transparent text-gray-400'}`}
              >
                {tabId}
              </button>
            ))}
          </div>

          {loading ? (
            <div className="text-center py-12 text-gray-400">{t('common.loading')}</div>
          ) : filteredOrders.length === 0 ? (
            <div className="text-center py-20 border border-dashed rounded-xl">
              <Package className="mx-auto text-gray-200 mb-4" size={48} />
              <p className="text-gray-500 font-medium">{t('orders.empty')}</p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredOrders.map((order) => (
                <div key={order.id} className="block border border-gray-100 rounded-2xl p-6 hover:shadow-md transition-all">
                  <div className="flex justify-between items-start mb-6">
                    <span className={`text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-widest
                      ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>
                      {order.status}
                    </span>
                    <Link href={`/orders/${order.id}`} className="bg-black text-white px-4 py-2 rounded-xl text-xs font-bold shadow-lg">Detail</Link>
                  </div>
                  <div className="flex gap-4">
                    <img src={order.items[0]?.product.images[0] || 'https://placehold.co/100'} className="w-16 h-16 rounded-xl object-cover" />
                    <div>
                      <p className="font-bold text-sm">{order.items[0]?.product.name}</p>
                      <p className="text-xs text-gray-400 mt-1">{new Date(order.createdAt).toLocaleDateString()}</p>
                      <p className="text-sm font-black mt-2">Rp {order.totalAmount.toLocaleString()}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </main>
      </div>
    </AuthGuard>
  );
}