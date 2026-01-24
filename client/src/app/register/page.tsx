'use client';

import { useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import toast from 'react-hot-toast';

export default function RegisterPage() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/auth/register`, {
        name,
        email,
        password
      });
      toast.success('Registrasi berhasil! Cek kode OTP di server.');
      // Pass userId to OTP page via query param or store, for simplicity using query here
      router.push(`/verify-otp?userId=${res.data.userId}&email=${email}`);
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Gagal mendaftar');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-md mx-auto px-8 py-24">
        <h1 className="text-4xl font-bold mb-2 tracking-tight">Buat Akun</h1>
        <p className="text-gray-500 mb-8">Bergabunglah dengan ArfCoder hari ini.</p>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-xs font-bold uppercase tracking-widest mb-2">Nama Lengkap</label>
            <input 
              type="text" 
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-4 py-3 border border-gray-200 focus:outline-none focus:border-black transition-colors"
              placeholder="Nama Anda"
              required
            />
          </div>
          <div>
            <label className="block text-xs font-bold uppercase tracking-widest mb-2">Email</label>
            <input 
              type="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 border border-gray-200 focus:outline-none focus:border-black transition-colors"
              placeholder="nama@email.com"
              required
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
              required
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full py-4 bg-black text-white font-medium hover:bg-gray-800 transition-colors disabled:bg-gray-400"
          >
            {loading ? 'Memproses...' : 'Daftar Sekarang'}
          </button>
        </form>

        <p className="mt-8 text-center text-sm text-gray-500">
          Sudah punya akun? <Link href="/login" className="text-black font-bold">Masuk</Link>
        </p>
      </main>
    </div>
  );
}
