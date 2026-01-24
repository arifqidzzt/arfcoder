'use client';

import { useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import toast from 'react-hot-toast';
import axios from 'axios';
import { useGoogleLogin } from '@react-oauth/google';

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
      const res = await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/auth/login`, {
        email,
        password
      });
      loginStore(res.data.user, res.data.token);
      toast.success('Berhasil masuk!');
      
      if (res.data.user.role === 'ADMIN' || res.data.user.role === 'SUPER_ADMIN') {
        router.push('/admin');
      } else {
        router.push('/');
      }
    } catch (error: any) {
      if (error.response?.status === 403) {
        toast.error('Silakan verifikasi email terlebih dahulu');
        router.push(`/verify-otp?userId=${error.response.data.userId}&email=${email}`);
      } else {
        toast.error(error.response?.data?.message || 'Gagal masuk');
      }
    } finally {
      setLoading(false);
    }
  };

  const googleLogin = useGoogleLogin({
    onSuccess: async (tokenResponse) => {
      try {
        const res = await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/auth/google`, {
          token: tokenResponse.credential || tokenResponse.access_token, // Handling different response types roughly, ideally use credential for ID token flow
        });
        // Note: For 'useGoogleLogin' implicit flow, we might need to fetch user info or use id_token flow. 
        // Simpler for this demo: Assume backend handles the access token validation or we switch to GoogleLogin component.
        // Let's stick to standard flow:
      } catch (err) {
        // Fallback for custom implementation
      }
    },
    flow: 'implicit' 
  });

  // Using the Component approach is often easier for ID Tokens
  const handleGoogleSuccess = async (credentialResponse: any) => {
    try {
      const res = await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/auth/google`, {
        token: credentialResponse.credential,
      });
      loginStore(res.data.user, res.data.token);
      toast.success('Berhasil masuk dengan Google!');
      router.push('/');
    } catch (error) {
      toast.error('Gagal login dengan Google');
    }
  };

  // Re-importing GoogleLogin component directly for cleaner UI integration
  const { GoogleLogin } = require('@react-oauth/google');

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-md mx-auto px-8 py-24">
        <h1 className="text-4xl font-bold mb-2 tracking-tight">Selamat Datang</h1>
        <p className="text-gray-500 mb-8">Masuk ke akun ArfCoder Anda.</p>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-xs font-bold uppercase tracking-widest mb-2">Email</label>
            <input 
              type="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 border border-gray-200 focus:outline-none focus:border-black transition-colors"
              placeholder="nama@email.com"
            />
          </div>
          <div>
            <label className="block text-xs font-bold uppercase tracking-widest mb-2">Password</label>
            <input 
              type="password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 border border-gray-200 focus:outline-none focus:border-black transition-colors"
              placeholder="••••••••"
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full py-4 bg-black text-white font-medium hover:bg-gray-800 transition-colors disabled:bg-gray-400"
          >
            {loading ? 'Memproses...' : 'Masuk'}
          </button>
        </form>

        <div className="relative my-8">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-200"></div>
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="px-2 bg-white text-gray-500">Atau masuk dengan</span>
          </div>
        </div>

        <div className="flex justify-center">
           <GoogleLogin
              onSuccess={handleGoogleSuccess}
              onError={() => toast.error('Login Failed')}
              useOneTap
              theme="filled_black"
              shape="pill"
              width="100%"
            />
        </div>

        <p className="mt-8 text-center text-sm text-gray-500">
          Belum punya akun? <Link href="/register" className="text-black font-bold">Daftar Sekarang</Link>
        </p>
      </main>
    </div>
  );
}