'use client';

import { useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { GoogleLogin } from '@react-oauth/google';
import { ArrowRight, Mail, Lock } from 'lucide-react';
import { useTranslation } from '@/lib/i18n';

export default function LoginPage() {
  const { t } = useTranslation();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const loginStore = useAuthStore((state) => state.login);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.post('/auth/login', { email, password });
      if (res.status === 202 && res.data.require2fa) {
        router.push(`/verify-admin?userId=${res.data.userId}&email=${res.data.email}`);
        return;
      }
      loginStore(res.data.user, res.data.token);
      toast.success(t('common.success'));
      router.push('/');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Invalid login');
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Navbar />
      <main className="flex-grow flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-md bg-white border p-8 rounded-3xl shadow-xl">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold mb-2">{t('auth.login_title')}</h1>
            <p className="text-muted-foreground">{t('auth.login_desc')}</p>
          </div>
          <form onSubmit={handleSubmit} className="space-y-5">
            <div className="space-y-2">
              <label className="text-sm font-medium">{t('auth.email')}</label>
              <input type="email" value={email} onChange={e => setEmail(e.target.value)} className="w-full p-3 bg-gray-50 border rounded-xl" required />
            </div>
            <div className="space-y-2">
              <div className="flex justify-between items-center">
                <label className="text-sm font-medium">{t('auth.password')}</label>
                <Link href="/forgot-password" size={12} className="text-xs font-bold text-accent">{t('auth.forgot_title')}</Link>
              </div>
              <input type="password" value={password} onChange={e => setPassword(e.target.value)} className="w-full p-3 bg-gray-50 border rounded-xl" required />
            </div>
            <button type="submit" disabled={loading} className="w-full py-4 bg-black text-white rounded-xl font-bold">{loading ? '...' : t('auth.btn_login')}</button>
          </form>
          <div className="mt-8 text-center text-sm text-gray-500">
            {t('auth.no_account')} <Link href="/register" className="text-accent font-bold underline">{t('auth.register_link')}</Link>
          </div>
        </div>
      </main>
    </div>
  );
}