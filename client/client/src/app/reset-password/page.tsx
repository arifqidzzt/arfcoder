'use client';

import { useState, Suspense } from 'react';
import Navbar from '@/components/Navbar';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { useRouter, useSearchParams } from 'next/navigation';

function ResetPasswordContent() {
  const [pass, setPass] = useState({ new: '', confirm: '' });
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get('token');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (pass.new !== pass.confirm) return toast.error('Password tidak sama');
    try {
      await api.post('/auth/reset-password', { token, newPassword: pass.new });
      toast.success('Password berhasil direset! Silakan login.');
      router.push('/login');
    } catch (error) { toast.error('Token invalid/expired'); }
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-md mx-auto px-8 py-32">
        <h1 className="text-3xl font-bold mb-4">Reset Password</h1>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input type="password" value={pass.new} onChange={e => setPass({...pass, new: e.target.value})} className="w-full p-4 border rounded-xl" placeholder="Password Baru" required />
          <input type="password" value={pass.confirm} onChange={e => setPass({...pass, confirm: e.target.value})} className="w-full p-4 border rounded-xl" placeholder="Konfirmasi Password" required />
          <button className="w-full py-4 bg-black text-white rounded-xl font-bold">Simpan Password Baru</button>
        </form>
      </main>
    </div>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <ResetPasswordContent />
    </Suspense>
  );
}
