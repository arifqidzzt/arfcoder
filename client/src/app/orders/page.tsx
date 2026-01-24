'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import { Package, ChevronRight, CreditCard } from 'lucide-react';
import Link from 'next/link';

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

export default function MyOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('ALL');
  const { token } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    const script = document.createElement('script');
    script.src = "https://app.sandbox.midtrans.com/snap/snap.js";
    script.setAttribute('data-client-key', process.env.NEXT_PUBLIC_MIDTRANS_CLIENT_KEY || '');
    document.body.appendChild(script);

    if (!token) { router.push('/login'); return; }
    
    const fetchOrders = async () => {
      try {
        const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/orders/my`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setOrders(res.data);
      } catch (error) { console.error(error); } finally { setLoading(false); }
    };
    fetchOrders();
  }, [token, router]);

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
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-4xl mx-auto px-4 sm:px-8 py-12 pt-24">
        <h1 className="text-3xl font-bold mb-8">Pesanan Saya</h1>

        <div className="flex border-b border-gray-100 mb-8 overflow-x-auto">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-6 py-3 text-sm font-medium whitespace-nowrap transition-colors border-b-2 
                ${activeTab === tab.id ? 'border-black text-black' : 'border-transparent text-gray-400 hover:text-gray-600'}`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {loading ? (
          <div className="text-center py-12 text-gray-400">Memuat...</div>
        ) : filteredOrders.length === 0 ? (
          <div className="text-center py-20 border border-dashed border-gray-200 rounded-xl bg-gray-50">
            <Package className="mx-auto text-gray-300 mb-4" size={48} />
            <p className="text-gray-500">Tidak ada pesanan di tab ini.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {filteredOrders.map((order) => (
              // STRUCTURE CHANGE: Div wrapper instead of Link wrapper
              <div key={order.id} className="block border border-gray-100 rounded-xl p-6 hover:shadow-md transition-all bg-white">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <span className={`text-[10px] font-bold px-2 py-1 rounded 
                      ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 
                        order.status === 'PENDING' ? 'bg-orange-100 text-orange-700' : 'bg-gray-100 text-gray-600'}`}>
                      {order.status}
                    </span>
                    <p className="text-xs text-gray-400 mt-2">{new Date(order.createdAt).toLocaleDateString('id-ID')}</p>
                  </div>
                  
                  {/* TOMBOL BAYAR TERPISAH DAN JELAS */}
                  {order.status === 'PENDING' ? (
                    <button 
                      onClick={() => handlePay(order.snapToken)}
                      className="bg-black text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-gray-800 flex items-center gap-2 cursor-pointer z-50"
                    >
                      <CreditCard size={14}/> Bayar
                    </button>
                  ) : (
                    <Link href={`/orders/${order.id}`} className="text-xs font-bold text-blue-600 hover:underline">
                      Lihat Detail
                    </Link>
                  )}
                </div>
                
                {/* Link hanya di area konten produk */}
                <Link href={`/orders/${order.id}`} className="flex gap-4 items-center group">
                  <img src={order.items[0]?.product.images[0] || 'https://placehold.co/100'} className="w-12 h-12 rounded bg-gray-100 object-cover" />
                  <div className="flex-1">
                    <p className="text-sm font-medium line-clamp-1 group-hover:text-blue-600 transition-colors">{order.items[0]?.product.name} {order.items.length > 1 && `+ ${order.items.length - 1} lainnya`}</p>
                    <p className="text-xs text-gray-500">Total: Rp {order.totalAmount.toLocaleString('id-ID')}</p>
                  </div>
                  <ChevronRight size={18} className="text-gray-300 group-hover:text-blue-600" />
                </Link>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}