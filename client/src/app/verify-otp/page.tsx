'use client';

import { useState, Suspense } from 'react';
import Navbar from '@/components/Navbar';
import { useRouter, useSearchParams } from 'next/navigation';
import axios from 'axios';
import toast from 'react-hot-toast';

function VerifyOtpContent() {
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const searchParams = useSearchParams();
  const userId = searchParams.get('userId');
  const email = searchParams.get('email');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/auth/verify-otp`, {
        userId,
        code
      });
      toast.success('Email berhasil diverifikasi! Silakan login.');
      router.push('/login');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Kode OTP salah atau kadaluarsa');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-md mx-auto px-8 py-24">
        <h1 className="text-4xl font-bold mb-2 tracking-tight">Verifikasi Email</h1>
        <p className="text-gray-500 mb-8">
          Masukkan kode 6 digit yang dikirim ke <span className="font-bold text-black">{email}</span>.
        </p>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-xs font-bold uppercase tracking-widest mb-2">Kode OTP</label>
            <input 
              type="text" 
              value={code}
              onChange={(e) => setCode(e.target.value)}
              maxLength={6}
              className="w-full px-4 py-3 border border-gray-200 focus:outline-none focus:border-black transition-colors text-center text-2xl tracking-[0.5em] font-mono"
              placeholder="000000"
              required
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full py-4 bg-black text-white font-medium hover:bg-gray-800 transition-colors disabled:bg-gray-400"
          >
            {loading ? 'Memverifikasi...' : 'Verifikasi Akun'}
          </button>
        </form>
      </main>
    </div>
  );
}

export default function VerifyOtpPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <VerifyOtpContent />
    </Suspense>
  );
}
