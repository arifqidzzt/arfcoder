'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import Link from 'next/link';
import { Package, ShoppingBag, Users, BarChart3, LogOut } from 'lucide-react';
import axios from 'axios';

export default function AdminDashboard() {
  const { user, logout, token } = useAuthStore();
  const router = useRouter();
  const [stats, setStats] = useState({ totalSales: 0, totalOrders: 0, totalProducts: 0, totalUsers: 0 });
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (mounted && (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN'))) {
      router.push('/login');
    }
  }, [user, mounted, router]);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/stats`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setStats(res.data);
      } catch (error) {
        console.error('Failed to fetch stats');
      }
    };
    
    if (token && mounted && user && (user.role === 'ADMIN' || user.role === 'SUPER_ADMIN')) {
      fetchStats();
    }
  }, [token, mounted, user]);

  if (!mounted) return null;
  if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) return null;

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r border-gray-200 fixed h-full hidden md:block z-10">
        <div className="p-6 border-b border-gray-100">
          <Link href="/" className="text-xl font-bold tracking-tighter hover:text-gray-600 transition-colors">ARF ADMIN</Link>
          <p className="text-xs text-gray-400 mt-1">Management Console</p>
        </div>
        <nav className="p-4 space-y-2">
          <Link href="/admin" className="flex items-center space-x-3 px-4 py-3 bg-black text-white rounded-lg">
            <BarChart3 size={20} />
            <span className="font-medium">Dashboard</span>
          </Link>
          <Link href="/admin/products" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <Package size={20} />
            <span className="font-medium">Produk</span>
          </Link>
          <Link href="/admin/orders" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <ShoppingBag size={20} />
            <span className="font-medium">Pesanan</span>
          </Link>
          <Link href="/admin/users" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <Users size={20} />
            <span className="font-medium">Pengguna</span>
          </Link>
          {/* Menu Baru */}
          <Link href="/admin/services" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <div className="w-5 h-5 flex items-center justify-center"><Package size={18}/></div> 
            <span className="font-medium">Layanan (Jasa)</span>
          </Link>
          <Link href="/admin/chat" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <div className="w-5 h-5 flex items-center justify-center"><div className="w-4 h-4 border-2 border-gray-400 rounded-full"/></div>
            <span className="font-medium">Live Chat</span>
          </Link>
          <Link href="/admin/whatsapp" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <div className="w-5 h-5 flex items-center justify-center">📱</div>
            <span className="font-medium">WhatsApp Bot</span>
          </Link>
          <div className="border-t border-gray-100 my-2"></div>
          <Link href="/" target="_blank" className="flex items-center space-x-3 px-4 py-3 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
            <div className="w-5 h-5 flex items-center justify-center">🌐</div>
            <span className="font-medium">Lihat Website</span>
          </Link>
        </nav>
        <div className="absolute bottom-0 w-full p-4 border-t border-gray-100">
          <button 
            onClick={() => { logout(); router.push('/'); }}
            className="flex items-center space-x-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-lg w-full transition-colors"
          >
            <LogOut size={20} />
            <span className="font-medium">Keluar</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 ml-0 md:ml-64 p-8">
        <header className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-2xl font-bold">Halo, {user.name}</h2>
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
            <p className="text-2xl font-bold mt-1">Rp {stats.totalSales.toLocaleString('id-ID')}</p>
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
      </main>
    </div>
  );
}