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

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const loginStore = useAuthStore((state) => state.login);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.post('/auth/login', {
        email,
        password
      });

      // Handle Admin 2FA Redirect
      if (res.status === 202 && res.data.require2fa) {
        toast.success('Verifikasi keamanan diperlukan');
        router.push(`/verify-admin?userId=${res.data.userId}&email=${res.data.email}`);
        return;
      }

      loginStore(res.data.user, res.data.token);
      toast.success('Berhasil masuk!');
      router.push('/');
    } catch (error: any) {
      if (error.response?.status === 403) {
        toast.error('Silakan verifikasi email terlebih dahulu');
        router.push(`/verify-otp?userId=${error.response.data.userId}&email=${email}`);
      } else {
        toast.error(error.response?.data?.message || 'Email atau password salah');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSuccess = async (credentialResponse: any) => {
    try {
      const res = await api.post('/auth/google', {
        token: credentialResponse.credential,
      });
      loginStore(res.data.user, res.data.token);
      toast.success('Berhasil masuk dengan Google!');
      router.push('/');
    } catch (error) {
      toast.error('Gagal login dengan Google');
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Navbar />
      <main className="flex-grow flex items-center justify-center px-4 py-12 relative overflow-hidden">
        {/* Background Blobs */}
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-accent/5 rounded-full blur-[100px] -z-10" />
        <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-accent/5 rounded-full blur-[100px] -z-10" />

        <div className="w-full max-w-md bg-white/50 backdrop-blur-xl border border-white/20 p-8 rounded-3xl shadow-xl">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold tracking-tight mb-2">Selamat Datang</h1>
            <p className="text-muted-foreground">Masuk untuk melanjutkan perjalanan digital Anda.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div className="space-y-2">
              <label className="text-sm font-medium ml-1">Email</label>
              <div className="relative">
                <Mail className="absolute left-4 top-3.5 text-gray-400" size={18} />
                <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/20 transition-all"
                  placeholder="nama@email.com"
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between items-center">
                <label className="text-sm font-medium ml-1">Password</label>
                <Link href="/forgot-password" className="text-xs font-bold text-accent hover:underline">
                  Lupa Password?
                </Link>
              </div>
              <div className="relative">
                <Lock className="absolute left-4 top-3.5 text-gray-400" size={18} />
                <input 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/20 transition-all"
                  placeholder="••••••••"
                  required
                />
              </div>
            </div>
            <button 
              type="submit" 
              disabled={loading}
              className="w-full py-3.5 bg-black text-white rounded-xl font-bold hover:bg-gray-800 transition-all active:scale-[0.98] flex items-center justify-center gap-2"
            >
              {loading ? 'Memproses...' : 'Masuk Sekarang'} <ArrowRight size={18} />
            </button>
          </form>

          <div className="relative my-8">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200"></div>
            </div>
            <div className="relative flex justify-center text-xs uppercase tracking-wider font-bold text-gray-400">
              <span className="px-2 bg-white/0 backdrop-blur-xl">Atau Lanjutkan Dengan</span>
            </div>
          </div>
            <div className="space-y-2">
              <label className="text-sm font-medium ml-1">Email</label>
              <div className="relative">
                <Mail className="absolute left-4 top-3.5 text-gray-400" size={18} />
                <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/20 transition-all"
                  placeholder="nama@email.com"
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between items-center">
                <label className="text-sm font-medium ml-1">Password</label>
                <Link href="/forgot-password" className="text-xs font-bold text-accent hover:underline">
                  Lupa Password?
                </Link>
              </div>
              <div className="relative">
                <Lock className="absolute left-4 top-3.5 text-gray-400" size={18} />
                <input 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/20 transition-all"
                  placeholder="••••••••"
                  required
                />
              </div>
            </div>
            <button 
              type="submit" 
              disabled={loading}
              className="w-full py-3.5 bg-black text-white rounded-xl font-bold hover:bg-gray-800 transition-all active:scale-[0.98] flex items-center justify-center gap-2"
            >
              {loading ? 'Memproses...' : 'Masuk Sekarang'} <ArrowRight size={18} />
            </button>
          </form>

          <div className="relative my-8">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200"></div>
            </div>
            <div className="relative flex justify-center text-xs uppercase tracking-wider font-bold text-gray-400">
              <span className="px-2 bg-white/0 backdrop-blur-xl">Atau Lanjutkan Dengan</span>
            </div>
          </div>

          <div className="flex justify-center">
             <GoogleLogin
                onSuccess={handleGoogleSuccess}
                onError={() => toast.error('Login Gagal')}
                useOneTap
                theme="filled_black"
                shape="pill"
                width="100%"
                text="continue_with"
              />
          </div>

          <p className="mt-8 text-center text-sm text-gray-500">
            Belum punya akun? <Link href="/register" className="text-accent font-bold hover:underline">Daftar Sekarang</Link>
          </p>
        </div>
      </main>
    </div>
  );
}
