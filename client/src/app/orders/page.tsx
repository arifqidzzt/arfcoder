'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import { Package, Clock, CheckCircle, XCircle } from 'lucide-react';

interface Order {
  id: string;
  invoiceNumber: string;
  totalAmount: number;
  status: string;
  createdAt: string;
  items: {
    product: { name: string; images: string[] };
    quantity: number;
    price: number;
  }[];
}

export default function MyOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const { user, token } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    if (!token) {
      router.push('/login');
      return;
    }

    const fetchOrders = async () => {
      try {
        const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/orders/my`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setOrders(res.data);
      } catch (error) {
        console.error('Failed to fetch orders');
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, [token, router]);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'PAID': return <span className="flex items-center gap-1 text-green-600 bg-green-50 px-3 py-1 rounded-full text-xs font-bold"><CheckCircle size={14}/> Lunas</span>;
      case 'PENDING': return <span className="flex items-center gap-1 text-orange-600 bg-orange-50 px-3 py-1 rounded-full text-xs font-bold"><Clock size={14}/> Menunggu</span>;
      case 'CANCELLED': return <span className="flex items-center gap-1 text-red-600 bg-red-50 px-3 py-1 rounded-full text-xs font-bold"><XCircle size={14}/> Dibatalkan</span>;
      default: return <span className="text-gray-500 bg-gray-100 px-3 py-1 rounded-full text-xs font-bold">{status}</span>;
    }
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-4xl mx-auto px-8 py-16">
        <h1 className="text-3xl font-bold mb-8">Riwayat Pesanan</h1>

        {loading ? (
          <div className="text-center py-12 text-gray-400">Memuat pesanan...</div>
        ) : orders.length === 0 ? (
          <div className="text-center py-12 border border-dashed border-gray-200 rounded-xl">
            <Package className="mx-auto text-gray-300 mb-4" size={48} />
            <p className="text-gray-500 mb-4">Anda belum memiliki pesanan.</p>
          </div>
        ) : (
          <div className="space-y-6">
            {orders.map((order) => (
              <div key={order.id} className="border border-gray-100 rounded-xl p-6 hover:shadow-sm transition-shadow">
                <div className="flex justify-between items-start mb-6 pb-6 border-b border-gray-50">
                  <div>
                    <p className="text-xs text-gray-400 mb-1">Invoice</p>
                    <p className="font-mono font-bold text-sm">{order.invoiceNumber}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-gray-400 mb-1">Status</p>
                    {getStatusBadge(order.status)}
                  </div>
                </div>

                <div className="space-y-4 mb-6">
                  {order.items.map((item, i) => (
                    <div key={i} className="flex gap-4">
                      <div className="w-16 h-16 bg-gray-100 rounded-lg overflow-hidden flex-shrink-0">
                        <img src={item.product.images[0] || 'https://placehold.co/100'} className="w-full h-full object-cover" />
                      </div>
                      <div>
                        <p className="font-medium text-sm">{item.product.name}</p>
                        <p className="text-xs text-gray-500">{item.quantity} x Rp {item.price.toLocaleString('id-ID')}</p>
                      </div>
                    </div>
                  ))}
                </div>

                <div className="flex justify-between items-center pt-4 border-t border-gray-50">
                  <span className="text-sm text-gray-500">{new Date(order.createdAt).toLocaleDateString('id-ID')}</span>
                  <span className="font-bold text-lg">Total: Rp {order.totalAmount.toLocaleString('id-ID')}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
