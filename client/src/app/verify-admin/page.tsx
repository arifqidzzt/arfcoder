'use client';

import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { ShieldCheck, Mail, Smartphone, ArrowRight, RefreshCw } from 'lucide-react';
import Navbar from '@/components/Navbar';

function VerifyContent() {
  const params = useSearchParams();
  const router = useRouter();
  const loginStore = useAuthStore((state) => state.login);
  
  const userId = params.get('userId');
  const email = params.get('email');

  const [step, setStep] = useState<'select' | 'input'>('select');
  const [method, setMethod] = useState<'authenticator' | 'email' | 'whatsapp'>('email');
  const [otpCode, setOtpCode] = useState('');
  const [loading, setLoading] = useState(false);
  
  // Timer
  const [countdown, setCountdown] = useState(0);

  useEffect(() => {
    if (!userId) {
      toast.error('Sesi tidak valid');
      router.push('/login');
    }
  }, [userId, router]);

  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (countdown > 0) {
      timer = setInterval(() => setCountdown(prev => prev - 1), 1000);
    }
    return () => clearInterval(timer);
  }, [countdown]);

  const handleSelectMethod = async (selected: 'authenticator' | 'email' | 'whatsapp') => {
    setMethod(selected);
    
    if (selected === 'authenticator') {
      setStep('input');
      return;
    }

    // Send OTP for Email/WA
    setLoading(true);
    try {
      await api.post('/auth/2fa/send', { userId, method: selected });
      toast.success(`OTP dikirim ke ${selected === 'email' ? 'Email' : 'WhatsApp'}`);
      setStep('input');
      setCountdown(60);
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Gagal mengirim OTP');
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.post('/auth/2fa/verify', {
        userId,
        code: otpCode,
        method
      });

      loginStore(res.data.user, res.data.token);
      toast.success('Login Admin Berhasil!');
      router.push('/admin');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Kode Verifikasi Salah');
    } finally {
      setLoading(false);
    }
  };

  const handleResend = () => {
    if (countdown > 0) return;
    handleSelectMethod(method);
  };

  return (
    <div className="w-full max-w-md bg-white border border-gray-200 p-8 rounded-3xl shadow-xl">
      <div className="text-center mb-8">
        <div className="mx-auto w-16 h-16 bg-black text-white rounded-full flex items-center justify-center mb-4">
          <ShieldCheck size={32} />
        </div>
        <h1 className="text-2xl font-bold tracking-tight mb-2">Verifikasi Keamanan</h1>
        <p className="text-muted-foreground text-sm">
          {step === 'select' 
            ? 'Pilih metode verifikasi untuk melanjutkan login Admin.' 
            : `Masukkan kode yang dikirim via ${method === 'authenticator' ? 'Google Authenticator' : method}.`}
        </p>
      </div>

      {step === 'select' ? (
        <div className="space-y-3">
          <button
            onClick={() => handleSelectMethod('authenticator')}
            className="w-full flex items-center p-4 border rounded-xl hover:bg-gray-50 transition-all group"
          >
            <div className="w-10 h-10 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center mr-4 group-hover:bg-blue-600 group-hover:text-white transition-colors">
              <ShieldCheck size={20} />
            </div>
            <div className="text-left">
              <h3 className="font-bold text-sm">Google Authenticator</h3>
              <p className="text-xs text-gray-500">Gunakan aplikasi Auth (Disarankan)</p>
            </div>
            <ArrowRight className="ml-auto text-gray-300 group-hover:text-black" size={18} />
          </button>

          <button
            onClick={() => handleSelectMethod('email')}
            className="w-full flex items-center p-4 border rounded-xl hover:bg-gray-50 transition-all group"
          >
            <div className="w-10 h-10 bg-orange-100 text-orange-600 rounded-lg flex items-center justify-center mr-4 group-hover:bg-orange-600 group-hover:text-white transition-colors">
              <Mail size={20} />
            </div>
            <div className="text-left">
              <h3 className="font-bold text-sm">Email OTP</h3>
              <p className="text-xs text-gray-500">Kirim kode ke {email || 'Email'}</p>
            </div>
            <ArrowRight className="ml-auto text-gray-300 group-hover:text-black" size={18} />
          </button>

          <button
            onClick={() => handleSelectMethod('whatsapp')}
            className="w-full flex items-center p-4 border rounded-xl hover:bg-gray-50 transition-all group"
          >
            <div className="w-10 h-10 bg-green-100 text-green-600 rounded-lg flex items-center justify-center mr-4 group-hover:bg-green-600 group-hover:text-white transition-colors">
              <Smartphone size={20} />
            </div>
            <div className="text-left">
              <h3 className="font-bold text-sm">WhatsApp</h3>
              <p className="text-xs text-gray-500">Kirim pesan ke nomor terdaftar</p>
            </div>
            <ArrowRight className="ml-auto text-gray-300 group-hover:text-black" size={18} />
          </button>
        </div>
      ) : (
        <form onSubmit={handleVerify} className="space-y-6">
          <div className="space-y-2">
            <div className="flex justify-between">
              <label className="text-sm font-medium">Kode Verifikasi</label>
              {method !== 'authenticator' && (
                <button 
                  type="button" 
                  onClick={handleResend}
                  disabled={countdown > 0}
                  className={`text-xs font-bold flex items-center gap-1 ${countdown > 0 ? 'text-gray-400' : 'text-blue-600 hover:underline'}`}
                >
                  <RefreshCw size={12} className={countdown > 0 ? 'animate-spin' : ''} />
                  {countdown > 0 ? `Kirim Ulang (${countdown}s)` : 'Kirim Ulang'}
                </button>
              )}
            </div>
            <input 
              type="text" 
              value={otpCode}
              onChange={(e) => setOtpCode(e.target.value.replace(/\D/g, ''))}
              className="w-full text-center text-3xl font-bold tracking-[0.5em] py-4 border rounded-xl focus:ring-2 focus:ring-black focus:outline-none"
              placeholder="000000"
              maxLength={6}
              autoFocus
              required
            />
          </div>

          <div className="flex gap-3">
            <button
              type="button"
              onClick={() => setStep('select')}
              className="px-6 py-3 border border-gray-200 rounded-xl font-bold hover:bg-gray-50 transition-all text-sm"
            >
              Ganti Metode
            </button>
            <button 
              type="submit" 
              disabled={loading}
              className="flex-1 py-3 bg-black text-white rounded-xl font-bold hover:bg-gray-800 transition-all flex items-center justify-center gap-2 shadow-lg shadow-black/20"
            >
              {loading ? 'Memverifikasi...' : 'Verifikasi'} <ArrowRight size={18} />
            </button>
          </div>
        </form>
      )}
    </div>
  );
}

export default function VerifyAdminPage() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <main className="flex-grow flex items-center justify-center px-4 py-12">
        <Suspense fallback={<div>Loading...</div>}>
          <VerifyContent />
        </Suspense>
      </main>
    </div>
  );
}
