'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Link from 'next/link';
import { Package, ShoppingBag, Users } from 'lucide-react';
import api from '@/lib/api';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function AdminDashboard() {
  const { user, token } = useAuthStore();
  const [showFullSales, setShowFullSales] = useState(false);
  const [stats, setStats] = useState({ 
    totalSales: 0, 
    totalOrders: 0, 
    totalProducts: 0, 
    totalUsers: 0,
    chart: { labels: [], data: [] } 
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await api.get('/admin/stats');
        setStats(res.data);
      } catch (error) { console.error('Failed to fetch stats'); }
    };
    if(token) fetchStats();
  }, [token]);

  const chartData = {
    labels: stats.chart?.labels || ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'],
    datasets: [
      {
        label: 'Pemasukan (Rupiah)',
        data: stats.chart?.data || [0, 0, 0, 0, 0, 0],
        borderColor: 'rgb(0, 0, 0)',
        backgroundColor: 'rgba(0, 0, 0, 0.05)',
        tension: 0.4,
        fill: true,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: { display: false },
      title: { display: true, text: 'Tren Pendapatan 6 Bulan Terakhir' },
    },
    scales: {
      y: { beginAtZero: true, grid: { display: false } },
      x: { grid: { display: false } }
    }
  };

  return (
    <div className="p-8">
      <header className="flex justify-between items-center mb-8">
        <div>
          <h2 className="text-2xl font-bold">Halo, {user?.name}</h2>
          <p className="text-gray-500">Berikut adalah ringkasan toko Anda hari ini.</p>
        </div>
      </header>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-blue-50 text-blue-600 rounded-xl">
              <ShoppingBag size={24} />
            </div>
          </div>
          <h3 className="text-gray-500 text-sm font-medium">Total Penjualan</h3>
          <p 
            onClick={() => setShowFullSales(!showFullSales)}
            className={`text-2xl font-bold mt-1 transition-all cursor-pointer ${showFullSales ? 'break-words' : 'truncate'}`} 
            title={showFullSales ? 'Klik untuk menyembunyikan' : `Rp ${stats.totalSales.toLocaleString('id-ID')}`}
          >
            Rp {stats.totalSales.toLocaleString('id-ID')}
          </p>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-purple-50 text-purple-600 rounded-xl">
              <Package size={24} />
            </div>
          </div>
          <h3 className="text-gray-500 text-sm font-medium">Total Produk</h3>
          <p className="text-2xl font-bold mt-1">{stats.totalProducts}</p>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-orange-50 text-orange-600 rounded-xl">
              <Users size={24} />
            </div>
          </div>
          <h3 className="text-gray-500 text-sm font-medium">Total User</h3>
          <p className="text-2xl font-bold mt-1">{stats.totalUsers}</p>
        </div>
        
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start mb-4">
            <div className="p-3 bg-green-50 text-green-600 rounded-xl">
              <ShoppingBag size={24} />
            </div>
          </div>
          <h3 className="text-gray-500 text-sm font-medium">Total Pesanan</h3>
          <p className="text-2xl font-bold mt-1">{stats.totalOrders}</p>
        </div>
      </div>

      {/* Chart Section */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-8">
        <h3 className="font-bold mb-6">Analisis Pendapatan</h3>
        <div className="h-64 w-full">
          <Line options={chartOptions} data={chartData} />
        </div>
      </div>

      {/* Recent Orders Placeholder */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-gray-100 flex justify-between items-center">
          <h3 className="font-bold">Pesanan Terbaru</h3>
          <Link href="/admin/orders" className="text-sm text-blue-600 hover:underline">Lihat Semua</Link>
        </div>
        <div className="p-6 text-center text-gray-400 py-12">
          Belum ada pesanan baru hari ini.
        </div>
      </div>
    </div>
  );
}
