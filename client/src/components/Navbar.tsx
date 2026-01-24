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
      <Link href="/" className="text-2xl font-bold tracking-tighter">
        ARFCODER
      </Link>
      <div className="hidden md:flex space-x-8 text-sm font-medium">
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
            <span className="text-sm font-medium hidden sm:inline">{user.name}</span>
            <button onClick={logout} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
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
