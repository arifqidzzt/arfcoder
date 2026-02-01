'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import { Package, ShoppingBag, Users, BarChart3, LogOut, Ticket, Zap, MessageSquare, Settings, History, Layers, Menu, X } from 'lucide-react';
import AuthGuard from '@/components/AuthGuard';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { logout } = useAuthStore();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const menuItems = [
    { href: '/admin', icon: <BarChart3 size={20} />, label: 'Dashboard' },
    { href: '/admin/products', icon: <Package size={20} />, label: 'Produk' },
    { href: '/admin/orders', icon: <ShoppingBag size={20} />, label: 'Pesanan' },
    { href: '/admin/users', icon: <Users size={20} />, label: 'Pengguna' },
    { href: '/admin/vouchers', icon: <Ticket size={20} />, label: 'Vouchers' },
    { href: '/admin/flash-sale', icon: <Zap size={20} />, label: 'Flash Sale' },
    { href: '/admin/services', icon: <Layers size={20} />, label: 'Layanan' },
    { href: '/admin/chat', icon: <MessageSquare size={20} />, label: 'Live Chat' },
    { href: '/admin/whatsapp', icon: <div className="w-5 h-5 flex items-center justify-center font-bold text-lg">📱</div>, label: 'WhatsApp Bot' },
    { href: '/admin/logs', icon: <History size={20} />, label: 'Audit Logs' },
  ];

  return (
    <AuthGuard adminOnly>
      <div className="min-h-screen bg-gray-50">
        
        {/* MOBILE HEADER (Visible only on Mobile) */}
        <div className="md:hidden bg-white border-b border-gray-200 p-4 flex justify-between items-center sticky top-0 z-30 shadow-sm">
          <Link href="/" className="text-xl font-bold tracking-tighter">ARF ADMIN</Link>
          <button onClick={() => setIsSidebarOpen(!isSidebarOpen)} className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg">
            {isSidebarOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* SIDEBAR (Desktop: Fixed, Mobile: Slide-in) */}
        <aside className={`
          fixed top-0 left-0 h-full w-64 bg-white border-r border-gray-200 z-40 transition-transform duration-300 ease-in-out
          ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'} 
          md:translate-x-0 md:block
        `}>
          <div className="p-6 border-b border-gray-100 flex justify-between items-center">
            <div>
              <Link href="/" className="text-xl font-bold tracking-tighter hover:text-gray-600 transition-colors">ARF ADMIN</Link>
              <p className="text-xs text-gray-400 mt-1">Management Console</p>
            </div>
            {/* Close button for mobile inside sidebar */}
            <button onClick={() => setIsSidebarOpen(false)} className="md:hidden p-1 text-gray-400">
              <X size={20} />
            </button>
          </div>

          <nav className="p-4 space-y-1 overflow-y-auto h-[calc(100vh-140px)]">
            {menuItems.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link 
                  key={item.href}
                  href={item.href}
                  onClick={() => setIsSidebarOpen(false)} 
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
            <Link href="/admin/profile" onClick={() => setIsSidebarOpen(false)} className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${pathname === '/admin/profile' ? 'bg-black text-white' : 'text-gray-600 hover:bg-gray-100'}`}>
              <Settings size={20} />
              <span className="font-medium">Pengaturan & 2FA</span>
            </Link>
            <Link href="/" target="_blank" className="flex items-center space-x-3 px-4 py-3 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
              <div className="w-5 h-5 flex items-center justify-center">🌐</div>
              <span className="font-medium">Lihat Website</span>
            </Link>
          </nav>
          
          <div className="absolute bottom-0 left-0 w-full p-4 border-t border-gray-100 bg-white">
            <button 
              onClick={() => { logout(); router.push('/'); }}
              className="flex items-center space-x-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-lg w-full transition-colors"
            >
              <LogOut size={20} />
              <span className="font-medium">Keluar</span>
            </button>
          </div>
        </aside>

        {/* OVERLAY (Mobile only) */}
        {isSidebarOpen && (
          <div 
            className="fixed inset-0 bg-black/50 z-30 md:hidden"
            onClick={() => setIsSidebarOpen(false)}
          />
        )}

        {/* MAIN CONTENT */}
        <div className="md:ml-64 min-h-screen transition-all duration-300 pt-20 md:pt-0">
            {children}
        </div>
      </div>
    </AuthGuard>
  );
}