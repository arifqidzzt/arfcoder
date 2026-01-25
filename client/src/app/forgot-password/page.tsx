'use client';

import { useState } from 'react';
import Navbar from '@/components/Navbar';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { useRouter } from 'next/navigation';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const router = useRouter();
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post('/auth/forgot-password', { email });
      router.push('/forgot-password/sent');
    } catch (error) { toast.error('Email tidak ditemukan'); }
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-md mx-auto px-8 py-32">
        <h1 className="text-3xl font-bold mb-4">Lupa Password?</h1>
        <p className="text-gray-500 mb-8">Masukkan email Anda untuk menerima link reset password.</p>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input type="email" value={email} onChange={e => setEmail(e.target.value)} className="w-full p-4 border rounded-xl" placeholder="Email Anda" required />
          <button className="w-full py-4 bg-black text-white rounded-xl font-bold">Kirim Link Reset</button>
        </form>
      </main>
    </div>
  );
}
