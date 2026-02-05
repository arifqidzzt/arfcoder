'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { useAuthStore } from '@/store/useAuthStore';
import Link from 'next/link';
import { ArrowLeft, RefreshCcw } from 'lucide-react';
import toast from 'react-hot-toast';

interface Order {
  id: string;
  invoiceNumber: string;
  totalAmount: number;
  status: string;
  user: { name: string; email: string };
  createdAt: string;
}

export default function AdminOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [activeTab, setActiveTab] = useState('ALL');
  const { token } = useAuthStore();

  const fetchOrders = async () => {
    try {
      const res = await api.get('/admin/orders');
      setOrders(res.data);
    } catch (error) {
      console.error('Failed to fetch orders');
    }
  };

  useEffect(() => {
    if (token) fetchOrders();
  }, [token]);

  // Filter Orders based on Tab
  const filteredOrders = orders.filter(o => {
    if (activeTab === 'ALL') return true;
    if (activeTab === 'UNPAID') return o.status === 'PENDING';
    if (activeTab === 'PROCESS') return o.status === 'PAID' || o.status === 'PROCESSING';
    if (activeTab === 'SHIPPED') return o.status === 'SHIPPED';
    if (activeTab === 'DONE') return o.status === 'COMPLETED';
    if (activeTab === 'CANCEL') return o.status === 'CANCELLED' || o.status === 'REFUND_REQUESTED';
    return false;
  });

  const tabs = [
    { id: 'ALL', label: 'Semua' },
    { id: 'UNPAID', label: 'Belum Bayar' },
    { id: 'PROCESS', label: 'Perlu Proses' },
    { id: 'SHIPPED', label: 'Dikirim' },
    { id: 'DONE', label: 'Selesai' },
    { id: 'CANCEL', label: 'Batal/Refund' },
  ];

  return (
    <div className="min-h-screen bg-gray-50 p-4 sm:p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
           <Link href="/admin" className="p-2 hover:bg-gray-200 rounded-full transition-colors">
             <ArrowLeft size={20} />
           </Link>
           <div>
              <h1 className="text-2xl font-bold">Manajemen Pesanan</h1>
              <p className="text-gray-500">Pantau dan update status pesanan masuk.</p>
           </div>
        </div>

        {/* Tab Navigation */}
        <div className="flex border-b border-gray-200 mb-6 overflow-x-auto bg-white rounded-t-xl px-4 pt-2">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-6 py-3 text-sm font-medium border-b-2 transition-colors whitespace-nowrap
                ${activeTab === tab.id ? 'border-black text-black' : 'border-transparent text-gray-400 hover:text-gray-600'}`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        <div className="bg-white rounded-b-xl border border-gray-200 border-t-0 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm min-w-[800px]">
              <thead className="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-4">Invoice</th>
                  <th className="px-6 py-4">Pelanggan</th>
                  <th className="px-6 py-4">Total</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Tanggal</th>
                  <th className="px-6 py-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filteredOrders.length === 0 ? (
                  <tr><td colSpan={6} className="text-center py-10 text-gray-400">Tidak ada pesanan di status ini.</td></tr>
                ) : (
                  filteredOrders.map((order) => (
                    <tr key={order.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 font-mono font-medium">{order.invoiceNumber}</td>
                      <td className="px-6 py-4">
                        <p className="font-medium">{order.user.name}</p>
                        <p className="text-xs text-gray-400">{order.user.email}</p>
                      </td>
                      <td className="px-6 py-4">Rp {order.totalAmount.toLocaleString('id-ID')}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 rounded text-xs font-bold 
                          ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : 
                            order.status === 'PENDING' ? 'bg-orange-100 text-orange-700' : 'bg-gray-100'}`}>
                          {order.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-gray-500">{new Date(order.createdAt).toLocaleDateString()}</td>
                      <td className="px-6 py-4 text-right">
                        <Link href={`/admin/orders/${order.id}`} className="inline-flex items-center gap-1 bg-black text-white px-3 py-1.5 rounded-lg text-xs font-bold hover:bg-gray-800 transition-colors">
                          Kelola
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}