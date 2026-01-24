'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import { Package, ShoppingBag, Users, BarChart3, LogOut, Settings } from 'lucide-react';

export default function AdminDashboard() {
  const { user, logout } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
      router.push('/login');
    }
  }, [user, router]);

  if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
    return <div className="min-h-screen flex items-center justify-center">Loading Admin Panel...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r border-gray-200 fixed h-full hidden md:block z-10">
        <div className="p-6 border-b border-gray-100">
          <h1 className="text-xl font-bold tracking-tighter">ARF ADMIN</h1>
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
          <Link href="/admin/settings" className="flex items-center space-x-3 px-4 py-3 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
            <Settings size={20} />
            <span className="font-medium">Pengaturan</span>
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
          <div className="md:hidden">
             {/* Mobile Menu Toggle could go here */}
             <span className="text-xs bg-black text-white px-2 py-1 rounded">ADMIN</span>
          </div>
        </header>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
            <div className="flex justify-between items-start mb-4">
              <div className="p-3 bg-blue-50 text-blue-600 rounded-xl">
                <ShoppingBag size={24} />
              </div>
              <span className="text-green-500 text-xs font-bold">+12%</span>
            </div>
            <h3 className="text-gray-500 text-sm font-medium">Total Penjualan</h3>
            <p className="text-2xl font-bold mt-1">Rp 15.2jt</p>
          </div>

          <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
            <div className="flex justify-between items-start mb-4">
              <div className="p-3 bg-purple-50 text-purple-600 rounded-xl">
                <Package size={24} />
              </div>
              <span className="text-green-500 text-xs font-bold">+5%</span>
            </div>
            <h3 className="text-gray-500 text-sm font-medium">Total Produk</h3>
            <p className="text-2xl font-bold mt-1">24</p>
          </div>

          <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
            <div className="flex justify-between items-start mb-4">
              <div className="p-3 bg-orange-50 text-orange-600 rounded-xl">
                <Users size={24} />
              </div>
              <span className="text-green-500 text-xs font-bold">+18%</span>
            </div>
            <h3 className="text-gray-500 text-sm font-medium">Total User</h3>
            <p className="text-2xl font-bold mt-1">1,203</p>
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
      </main>
    </div>
  );
}
