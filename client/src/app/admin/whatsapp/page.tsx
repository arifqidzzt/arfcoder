'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import api from '@/lib/api';
import { io } from 'socket.io-client';
import { Smartphone, RefreshCcw, LogOut } from 'lucide-react';
import QRCode from 'react-qr-code';

export default function AdminWhatsAppPage() {
  const { token } = useAuthStore();
  const [status, setStatus] = useState('DISCONNECTED');
  const [qr, setQr] = useState('');

  useEffect(() => {
    fetchStatus();
    const interval = setInterval(fetchStatus, 3000);
    return () => clearInterval(interval);
  }, []);

  const fetchStatus = async () => {
    try {
      const res = await api.get('/admin/wa/status');
      setStatus(res.data.status);
      if (res.data.qr) setQr(res.data.qr);
    } catch (err) { console.error(err); }
  };

  const handleStart = async () => {
    await api.post('/admin/wa/start', {});
  };

  const handleLogout = async () => {
    await api.post('/admin/wa/logout', {});
    setStatus('DISCONNECTED');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <main className="max-w-4xl mx-auto px-8 py-24">
        <h1 className="text-3xl font-bold mb-8">WhatsApp Bot Control</h1>

        <div className="bg-white p-8 rounded-3xl shadow-lg border border-gray-100 text-center">
          <div className={`w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 ${status === 'CONNECTED' ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-400'}`}>
            <Smartphone size={40} />
          </div>
          
          <h2 className="text-xl font-bold mb-2">Status: {status}</h2>
          <p className="text-gray-500 mb-8">Gunakan bot ini untuk mengirim OTP ke user.</p>

          {status === 'DISCONNECTED' && (
            <button onClick={handleStart} className="px-8 py-3 bg-black text-white rounded-xl font-bold hover:scale-105 transition-transform">
              Mulai Sesi Baru
            </button>
          )}

          {(status === 'Scan QR' || qr) && (
            <div className="bg-white p-4 inline-block rounded-xl border border-gray-200">
              <QRCode value={qr} />
              <p className="mt-4 text-sm text-gray-500">Scan dengan WhatsApp di HP Anda</p>
            </div>
          )}

          {status === 'CONNECTED' && (
            <button onClick={handleLogout} className="px-8 py-3 bg-red-600 text-white rounded-xl font-bold hover:bg-red-700 flex items-center gap-2 mx-auto">
              <LogOut size={18}/> Logout Sesi
            </button>
          )}
        </div>
      </main>
    </div>
  );
}
