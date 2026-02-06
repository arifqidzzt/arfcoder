'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { ShoppingBag, User, LogOut, Menu, X, Globe, ChevronRight } from 'lucide-react';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { useTranslation } from '@/lib/i18n';

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const cartItems = useCartStore((state) => state.items);
  const { user, logout } = useAuthStore();
  const { t, language, setLanguage } = useTranslation();

  // Tutup sidebar saat pindah halaman
  useEffect(() => {
    setIsOpen(false);
  }, []);

  const toggleMenu = () => setIsOpen(!isOpen);

  const NavLinks = () => (
    <>
      <Link href="/" className="hover:text-black transition-colors">{t('navbar.home')}</Link>
      <Link href="/products" className="hover:text-black transition-colors">{t('navbar.products')}</Link>
      <Link href="/services" className="hover:text-black transition-colors">{t('navbar.services')}</Link>
      {user && <Link href="/orders" className="hover:text-black transition-colors">{t('navbar.orders')}</Link>}
      {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
        <Link href="/admin" className="text-purple-600 font-bold hover:text-purple-800 transition-colors">
          {t('navbar.admin')}
        </Link>
      )}
    </>
  );

  return (
    <>
      <nav className="flex items-center justify-between px-6 md:px-12 py-4 border-b border-gray-100 bg-white/80 backdrop-blur-md sticky top-0 z-[60] transition-all">
        {/* LOGO */}
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-9 h-9 flex items-center justify-center overflow-hidden rounded-lg">
            <img src="/app_icon.png" alt="Logo" className="w-full h-full object-cover" />
          </div>
          <span className="text-xl font-black tracking-tighter">ARFCODER</span>
        </Link>

        {/* DESKTOP LINKS */}
        <div className="hidden md:flex items-center space-x-8 text-sm font-semibold text-gray-500">
          <NavLinks />
        </div>

        {/* RIGHT ACTIONS */}
        <div className="flex items-center space-x-3">
          {/* Desktop Language Selector */}
          <div className="hidden md:flex items-center bg-gray-100 rounded-full p-1 border border-gray-200">
            <button 
              onClick={() => setLanguage('id')}
              className={`px-2.5 py-1 text-[10px] font-black rounded-full transition-all ${language === 'id' ? 'bg-white shadow-sm text-black' : 'text-gray-400'}`}
            >
              ID
            </button>
            <button 
              onClick={() => setLanguage('en')}
              className={`px-2.5 py-1 text-[10px] font-black rounded-full transition-all ${language === 'en' ? 'bg-white shadow-sm text-black' : 'text-gray-400'}`}
            >
              EN
            </button>
          </div>

          {user ? (
            <div className="hidden md:flex items-center space-x-3">
              <Link href="/profile" className="w-9 h-9 rounded-full border-2 border-gray-100 p-0.5 overflow-hidden hover:border-black transition-all">
                <img src={user.avatar || `https://ui-avatars.com/api/?name=${user.name}`} className="w-full h-full rounded-full object-cover" alt="Profile" />
              </Link>
              <button onClick={logout} className="p-2 text-gray-400 hover:text-red-500 transition-colors"><LogOut size={20} /></button>
            </div>
          ) : (
            <Link href="/login" className="hidden md:block p-2 text-gray-500 hover:text-black transition-colors"><User size={20} /></Link>
          )}

          <Link href="/cart" className="p-2.5 bg-black text-white rounded-full relative hover:scale-105 transition-all shadow-lg shadow-black/10">
            <ShoppingBag size={18} />
            {cartItems.length > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-[9px] font-bold w-4 h-4 flex items-center justify-center rounded-full ring-2 ring-white">
                {cartItems.length}
              </span>
            )}
          </Link>

          {/* MOBILE MENU BUTTON */}
          <button onClick={toggleMenu} className="md:hidden p-2 text-black hover:bg-gray-100 rounded-xl transition-colors">
            {isOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </nav>

      {/* MOBILE SIDEBAR OVERLAY */}
      <div className={`fixed inset-0 bg-black/40 z-[70] transition-opacity duration-300 md:hidden ${isOpen ? 'opacity-100 visible' : 'opacity-0 invisible'}`} onClick={toggleMenu} />
      
      {/* MOBILE SIDEBAR DRAWER */}
      <aside className={`fixed top-0 right-0 h-full w-[80%] max-w-xs bg-white z-[80] shadow-2xl transition-transform duration-300 ease-out md:hidden ${isOpen ? 'translate-x-0' : 'translate-x-full'}`}>
        <div className="flex flex-col h-full">
          {/* Header Sidebar */}
          <div className="p-6 border-b border-gray-50 flex items-center justify-between">
            <span className="font-black tracking-tighter text-lg">{t('navbar.menu')}</span>
            <button onClick={toggleMenu} className="p-2 hover:bg-gray-50 rounded-lg"><X size={20}/></button>
          </div>

          {/* Menu Links */}
          <div className="flex-1 overflow-y-auto p-6 space-y-2">
            <div className="flex flex-col space-y-4 text-lg font-bold text-gray-900">
              <Link href="/" onClick={toggleMenu} className="flex items-center justify-between py-2 border-b border-gray-50">
                {t('navbar.home')} <ChevronRight size={18} className="text-gray-300"/>
              </Link>
              <Link href="/products" onClick={toggleMenu} className="flex items-center justify-between py-2 border-b border-gray-50">
                {t('navbar.products')} <ChevronRight size={18} className="text-gray-300"/>
              </Link>
              <Link href="/services" onClick={toggleMenu} className="flex items-center justify-between py-2 border-b border-gray-50">
                {t('navbar.services')} <ChevronRight size={18} className="text-gray-300"/>
              </Link>
              {user && (
                <Link href="/orders" onClick={toggleMenu} className="flex items-center justify-between py-2 border-b border-gray-50">
                  {t('navbar.orders')} <ChevronRight size={18} className="text-gray-300"/>
                </Link>
              )}
              {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
                <Link href="/admin" onClick={toggleMenu} className="flex items-center justify-between py-2 text-purple-600">
                  {t('navbar.admin')} <ChevronRight size={18} className="text-purple-200"/>
                </Link>
              )}
            </div>

            {/* Language Switcher in Mobile */}
            <div className="mt-12">
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">{t('navbar.language')}</p>
              <div className="grid grid-cols-2 gap-2">
                <button 
                  onClick={() => setLanguage('id')}
                  className={`py-3 rounded-xl border-2 font-bold text-sm transition-all ${language === 'id' ? 'border-black bg-black text-white' : 'border-gray-100 text-gray-400'}`}
                >
                  Bahasa Indonesia
                </button>
                <button 
                  onClick={() => setLanguage('en')}
                  className={`py-3 rounded-xl border-2 font-bold text-sm transition-all ${language === 'en' ? 'border-black bg-black text-white' : 'border-gray-100 text-gray-400'}`}
                >
                  English
                </button>
              </div>
            </div>
          </div>

          {/* Footer Sidebar (Auth) */}
          <div className="p-6 border-t border-gray-50">
            {user ? (
              <div className="space-y-4">
                <Link href="/profile" onClick={toggleMenu} className="flex items-center gap-3 p-3 bg-gray-50 rounded-2xl">
                  <img src={user.avatar || `https://ui-avatars.com/api/?name=${user.name}`} className="w-10 h-10 rounded-full object-cover border border-white shadow-sm" alt="" />
                  <div>
                    <p className="text-sm font-bold leading-none">{user.name}</p>
                    <p className="text-[10px] text-gray-400 mt-1 uppercase font-bold">{user.role}</p>
                  </div>
                </Link>
                <button onClick={() => { logout(); toggleMenu(); }} className="w-full py-4 text-red-500 font-bold flex items-center justify-center gap-2 hover:bg-red-50 rounded-2xl transition-colors">
                  <LogOut size={18} /> {t('navbar.logout')}
                </button>
              </div>
            ) : (
              <Link href="/login" onClick={toggleMenu} className="w-full py-4 bg-black text-white font-bold rounded-2xl flex items-center justify-center gap-2">
                <User size={18} /> {t('navbar.login')}
              </Link>
            )}
          </div>
        </div>
      </aside>
    </>
  );
}
