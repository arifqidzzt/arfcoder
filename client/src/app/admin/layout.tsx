'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import { Package, ShoppingBag, Users, BarChart3, LogOut, Ticket, Zap, MessageSquare } from 'lucide-react';
import AuthGuard from '@/components/AuthGuard';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { logout } = useAuthStore();

  const menuItems = [
    { href: '/admin', icon: <BarChart3 size={20} />, label: 'Dashboard' },
    { href: '/admin/products', icon: <Package size={20} />, label: 'Produk' },
    { href: '/admin/orders', icon: <ShoppingBag size={20} />, label: 'Pesanan' },
    { href: '/admin/users', icon: <Users size={20} />, label: 'Pengguna' },
    { href: '/admin/vouchers', icon: <Ticket size={20} />, label: 'Vouchers' },
    { href: '/admin/flash-sale', icon: <Zap size={20} />, label: 'Flash Sale' },
    { href: '/admin/services', icon: <div className="w-5 h-5 flex items-center justify-center font-bold text-xs border rounded">S</div>, label: 'Layanan' },
    { href: '/admin/chat', icon: <MessageSquare size={20} />, label: 'Live Chat' },
    { href: '/admin/whatsapp', icon: <div className="w-5 h-5 flex items-center justify-center">📱</div>, label: 'WhatsApp Bot' },
  ];

  return (
    <AuthGuard adminOnly>
      <div className="min-h-screen bg-gray-50 flex">
        {/* Sidebar */}
        <aside className="w-64 bg-white border-r border-gray-200 fixed h-full hidden md:block z-20 overflow-y-auto">
          <div className="p-6 border-b border-gray-100">
            <Link href="/" className="text-xl font-bold tracking-tighter hover:text-gray-600 transition-colors">ARF ADMIN</Link>
            <p className="text-xs text-gray-400 mt-1">Management Console</p>
          </div>
          <nav className="p-4 space-y-1">
            {menuItems.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link 
                  key={item.href}
                  href={item.href} 
                  className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                    isActive ? 'bg-black text-white font-medium shadow-md' : 'text-gray-600 hover:bg-gray-100'
                  }`}
                >
                  {item.icon}
                  <span className="font-medium">{item.label}</span>
                </Link>
              );
            })}
            
            <div className="border-t border-gray-100 my-2"></div>
            <Link href="/" target="_blank" className="flex items-center space-x-3 px-4 py-3 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
              <div className="w-5 h-5 flex items-center justify-center">🌐</div>
              <span className="font-medium">Lihat Website</span>
            </Link>
          </nav>
          <div className="p-4 mt-auto">
            <button 
              onClick={() => { logout(); router.push('/'); }}
              className="flex items-center space-x-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-lg w-full transition-colors"
            >
              <LogOut size={20} />
              <span className="font-medium">Keluar</span>
            </button>
          </div>
        </aside>

        {/* Main Content Wrapper */}
        <div className="flex-1 ml-0 md:ml-64 w-full">
            {children}
        </div>
      </div>
    </AuthGuard>
  );
}
