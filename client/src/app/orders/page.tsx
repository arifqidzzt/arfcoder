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
    if (activeTab === 'PROCESS') return ['PAID', 'PROCESSING', 'SHIPPED'].includes(o.status);
    if (activeTab === 'DONE') return ['COMPLETED'].includes(o.status);
    return false;
  });

  const tabs = [
    { id: 'ALL', label: 'All' },
    { id: 'UNPAID', label: 'Unpaid' },
    { id: 'PROCESS', label: 'Process' },
    { id: 'DONE', label: 'Done' },
  ];

  return (
    <AuthGuard>
      <div className="min-h-screen bg-white">
        <Navbar />
        <main className="max-w-4xl mx-auto px-4 sm:px-8 py-12 pt-24">
          <h1 className="text-3xl font-black mb-8 tracking-tighter">{t('orders.list_title')}</h1>

          <div className="flex border-b border-gray-100 mb-8 overflow-x-auto bg-white rounded-t-xl px-2">
            {tabs.map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-6 py-4 text-sm font-black whitespace-nowrap transition-all border-b-2 
                  ${activeTab === tab.id ? 'border-black text-black' : 'border-transparent text-gray-400 hover:text-gray-600'}`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {loading ? (
            <div className="text-center py-12 text-gray-400 font-bold">{t('common.loading')}</div>
          ) : filteredOrders.length === 0 ? (
            <div className="text-center py-20 border border-dashed border-gray-200 rounded-[2rem] bg-gray-50/30">
              <Package className="mx-auto text-gray-200 mb-4" size={48} />
              <p className="text-gray-500 font-bold">{t('orders.empty')}</p>
            </div>
          ) : (
            <div className="space-y-6">
              {filteredOrders.map((order) => (
                <div key={order.id} className="block border border-gray-100 rounded-[2rem] p-8 hover:shadow-2xl transition-all bg-white relative group">
                  <div className="flex justify-between items-start mb-8">
                    <div className="space-y-3">
                      <span className={`text-[10px] font-black uppercase tracking-[0.2em]
                        ${order.status === 'PAID' ? 'text-green-600' : 
                          order.status === 'PENDING' ? 'text-orange-600' : 
                          order.status === 'CANCELLED' ? 'text-red-600' :
                          'text-gray-600'}`}>
                        {order.status}
                      </span>
                      
                      {order.status === 'PENDING' && (
                        <div className="flex items-center gap-2 text-red-600">
                          <span className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50">{t('orders.limit')}:</span>
                          <CountdownTimer dateString={order.createdAt} />
                        </div>
                      )}
                    </div>
                    
                    <Link href={`/orders/${order.id}`} className="bg-black text-white px-6 py-2.5 rounded-xl text-xs font-black hover:bg-gray-800 flex items-center gap-2 transition-all shadow-xl shadow-black/10 active:scale-95">
                      {order.status === 'PENDING' ? <><CreditCard size={14}/> Pay</> : 'Details'}
                    </Link>
                  </div>
                  
                  <Link href={`/orders/${order.id}`} className="flex gap-6 items-center">
                    <div className="w-20 h-20 rounded-2xl bg-gray-50 overflow-hidden border border-gray-100 flex-shrink-0 shadow-inner">
                      <img src={order.items[0]?.product.images[0] || 'https://placehold.co/100'} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-lg font-black text-gray-900 truncate group-hover:text-accent transition-colors">
                        {order.items[0]?.product.name} {order.items.length > 1 && `+ ${order.items.length - 1} more`}
                      </p>
                      <p className="text-xs text-gray-400 font-bold mt-1 uppercase tracking-widest">{new Date(order.createdAt).toLocaleDateString()}</p>
                      <p className="text-xl font-black mt-3 text-black">Rp {order.totalAmount.toLocaleString('id-ID')}</p>
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