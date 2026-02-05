'use client';

import Link from 'next/link';
import { ShoppingBag, User, LogOut } from 'lucide-react';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';

export default function Navbar() {
  const cartItems = useCartStore((state) => state.items);
  const { user, logout } = useAuthStore();

  return (
    <nav className="flex items-center justify-between px-8 py-4 border-b border-border/40 bg-background/80 backdrop-blur-md sticky top-0 z-50 transition-all">
      <Link href="/" className="flex items-center gap-3 group">
        <div className="w-10 h-10 flex items-center justify-center overflow-hidden">
          <img src="/app_icon.png" alt="Logo" className="w-full h-full object-cover" />
        </div>
        <span className="text-xl font-bold tracking-tighter">ARFCODER</span>
      </Link>
      <div className="hidden md:flex space-x-8 text-sm font-medium">
        <Link href="/" className="hover:text-gray-600 transition-colors">Beranda</Link>
        <Link href="/products" className="hover:text-gray-600 transition-colors">Produk</Link>
        <Link href="/services" className="hover:text-gray-600 transition-colors">Jasa</Link>
        {user && <Link href="/orders" className="hover:text-gray-600 transition-colors">Pesanan</Link>}
        {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
          <Link href="/admin" className="text-purple-600 font-bold hover:text-purple-800 transition-colors">Dashboard</Link>
        )}
      </div>
      <div className="flex items-center space-x-4">
        {user ? (
          <div className="flex items-center space-x-4">
            <Link href="/profile" className="flex items-center gap-2 hover:bg-gray-50 px-3 py-2 rounded-full transition-colors group">
              <div className="w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs overflow-hidden border border-gray-200">
                {user.avatar ? (
                  <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
                ) : (
                  <span className="text-black">{user.name?.charAt(0).toUpperCase()}</span>
                )}
              </div>
              <span className="text-sm font-medium hidden sm:inline group-hover:text-black">{user.name}</span>
            </Link>
            <button onClick={logout} className="p-2 hover:bg-red-50 text-gray-400 hover:text-red-500 rounded-full transition-colors" title="Keluar">
              <LogOut size={18} />
            </button>
          </div>
        ) : (
          <Link href="/login" className="p-2 hover:bg-gray-100 rounded-full transition-colors">
            <User size={18} />
          </Link>
        )}
        <Link href="/cart" className="p-2 bg-black text-white rounded-full relative hover:bg-gray-800 transition-colors">
          <ShoppingBag size={18} />
          {cartItems.length > 0 && (
            <span className="absolute -top-1 -right-1 bg-accent text-[10px] w-4 h-4 flex items-center justify-center rounded-full">
              {cartItems.length}
            </span>
          )}
        </Link>
      </div>
    </nav>
  );
}
