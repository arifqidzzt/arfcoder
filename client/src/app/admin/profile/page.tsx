'use client';

import { useState, useEffect } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Shield, ShieldCheck, Copy, Check } from 'lucide-react';

export default function AdminProfilePage() {
  const { user } = useAuthStore();
  const [setupStep, setSetupStep] = useState<'idle' | 'qr' | 'verify'>('idle');
  const [qrCode, setQrCode] = useState('');
  const [secret, setSecret] = useState('');
  const [token, setToken] = useState('');
  const [isEnabled, setIsEnabled] = useState(false); // Should fetch from API ideally

  const handleStartSetup = async () => {
    try {
      const res = await api.post('/auth/2fa/setup', { userId: user?.id });
      setQrCode(res.data.qrCode);
      setSecret(res.data.secret);
      setSetupStep('qr');
    } catch (error: any) {
      toast.error('Gagal generate QR');
    }
  };

  const handleEnable = async () => {
    try {
      await api.post('/auth/2fa/enable', { userId: user?.id, token });
      toast.success('Google Authenticator Berhasil Diaktifkan!');
      setIsEnabled(true);
      setSetupStep('idle');
    } catch (error: any) {
      toast.error('Kode salah, coba lagi');
    }
  };

  return (
    <div className="p-8 max-w-4xl">
      <h1 className="text-3xl font-bold mb-8">Pengaturan Akun</h1>

      <div className="bg-white p-8 rounded-2xl border border-gray-100 shadow-sm mb-8">
        <h2 className="text-xl font-bold mb-4">Profil Admin</h2>
        <div className="space-y-4">
          <div>
            <label className="text-sm text-gray-500 block">Nama</label>
            <p className="font-medium text-lg">{user?.name}</p>
          </div>
          <div>
            <label className="text-sm text-gray-500 block">Email</label>
            <p className="font-medium text-lg">{user?.email}</p>
          </div>
          <div>
            <label className="text-sm text-gray-500 block">Role</label>
            <span className="px-3 py-1 bg-black text-white text-xs rounded-full font-bold">{user?.role}</span>
          </div>
        </div>
      </div>

      <div className="bg-white p-8 rounded-2xl border border-gray-100 shadow-sm">
        <div className="flex items-center gap-4 mb-6">
          <div className={`p-3 rounded-xl ${isEnabled ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-600'}`}>
            {isEnabled ? <ShieldCheck size={24} /> : <Shield size={24} />}
          </div>
          <div>
            <h2 className="text-xl font-bold">Keamanan 2-Langkah (2FA)</h2>
            <p className="text-gray-500 text-sm">Gunakan Google Authenticator untuk login yang lebih aman.</p>
          </div>
        </div>

        {setupStep === 'idle' && (
          <button 
            onClick={handleStartSetup}
            className="px-6 py-3 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-colors"
          >
            {isEnabled ? 'Setup Ulang Authenticator' : 'Aktifkan Google Authenticator'}
          </button>
        )}

        {setupStep === 'qr' && (
          <div className="bg-gray-50 p-6 rounded-xl border border-gray-200 animate-in fade-in zoom-in duration-300">
            <h3 className="font-bold mb-4">Langkah 1: Scan QR Code</h3>
            <p className="text-sm text-gray-600 mb-4">Buka aplikasi Google Authenticator di HP Anda, lalu scan kode ini:</p>
            
            <div className="flex flex-col md:flex-row gap-8 items-center bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
              <div className="bg-white p-4 rounded-xl border border-gray-200">
                <img src={qrCode} alt="2FA QR" className="w-48 h-48 mx-auto" />
              </div>
              <div className="flex-1 space-y-4 w-full">
                <div>
                  <label className="text-xs font-bold text-gray-500 uppercase">Atau masukkan kode manual:</label>
                  <div className="flex items-center gap-2 mt-1 w-full">
                    <div className="relative flex-1 group cursor-pointer" onClick={() => {navigator.clipboard.writeText(secret); toast.success('Disalin!')}}>
                      <code className="block w-full bg-gray-50 px-4 py-3 rounded-lg border font-mono font-bold tracking-widest text-lg break-all text-center md:text-left hover:bg-gray-100 transition-colors">
                        {secret}
                      </code>
                      <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 bg-black/5 transition-opacity rounded-lg">
                        <span className="text-xs font-bold text-black bg-white px-2 py-1 rounded shadow">Klik Salin</span>
                      </div>
                    </div>
                    <button onClick={() => {navigator.clipboard.writeText(secret); toast.success('Disalin!')}} className="p-3 bg-gray-100 hover:bg-gray-200 rounded-lg text-gray-600 transition-colors shrink-0">
                      <Copy size={20} />
                    </button>
                  </div>
                </div>
                
                <div className="pt-4 border-t border-gray-200">
                  <h3 className="font-bold mb-2">Langkah 2: Verifikasi</h3>
                  <p className="text-sm text-gray-600 mb-2">Masukkan 6 digit kode yang muncul di aplikasi untuk mengaktifkan.</p>
                  <div className="flex gap-2">
                    <input 
                      type="text" 
                      value={token}
                      onChange={e => setToken(e.target.value.replace(/\D/g,''))}
                      placeholder="000000"
                      className="w-32 text-center font-bold tracking-widest p-3 rounded-xl border focus:outline-none focus:ring-2 focus:ring-black"
                      maxLength={6}
                    />
                    <button 
                      onClick={handleEnable}
                      className="flex-1 px-4 py-3 bg-black text-white rounded-xl font-bold hover:bg-gray-800 flex items-center justify-center gap-2"
                    >
                      <Check size={18} /> Aktifkan
                    </button>
                  </div>
                </div>
              </div>
            </div>
            
            <button onClick={() => setSetupStep('idle')} className="mt-6 text-sm text-gray-500 hover:text-black underline">
              Batalkan Setup
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
