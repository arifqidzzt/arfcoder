'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import Link from 'next/link'; // Added Link import
import api from '@/lib/api';
import { User, Mail, Phone, Lock, Edit, Camera, LogOut } from 'lucide-react';
import toast from 'react-hot-toast';
import AuthGuard from '@/components/AuthGuard';

export default function ProfilePage() {
  const { user, token, logout } = useAuthStore();
  const router = useRouter();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  
  // States for modals
  const [showEdit, setShowEdit] = useState(false);
  const [showPass, setShowPass] = useState(false);
  const [showEmail, setShowEmail] = useState(false);
  const [showPhone, setShowPhone] = useState(false);
  
  // Forms
  const [newName, setNewName] = useState('');
  const [newAvatar, setNewAvatar] = useState('');
  
  const [passData, setPassData] = useState({ old: '', new: '', confirm: '' });
  
  const [emailStep, setEmailStep] = useState(1);
  const [emailForm, setEmailForm] = useState({ newEmail: '', code: '' });

  const [phoneStep, setPhoneStep] = useState(1);
  const [phoneForm, setPhoneForm] = useState({ newPhone: '', code: '' });

  useEffect(() => {
    if (token) fetchProfile();
  }, [token]);

  const fetchProfile = async () => {
    try {
      const res = await api.get('/user/profile');
      setProfile(res.data);
      setNewName(res.data.name);
      setNewAvatar(res.data.avatar || '');
    } catch (error) { toast.error('Gagal load profile'); } finally { setLoading(false); }
  };

  const handleUpdateProfile = async () => {
    try {
      await api.put('/user/profile', { name: newName, avatar: newAvatar });
      toast.success('Profil diperbarui');
      setShowEdit(false);
      fetchProfile();
    } catch (error) { toast.error('Gagal update'); }
  };

  const handleChangePassword = async () => {
    if (passData.new !== passData.confirm) return toast.error('Password tidak cocok');
    try {
      await api.put('/user/password', { oldPassword: passData.old, newPassword: passData.new });
      toast.success('Password diubah');
      setShowPass(false);
    } catch (error: any) { toast.error(error.response?.data?.message || 'Gagal'); }
  };

  const handleEmailChange = async () => {
    try {
      if (emailStep === 1) {
        await api.post('/user/email/request', {});
        setEmailStep(2);
        toast.success('OTP dikirim ke email lama');
      } else if (emailStep === 2) {
        await api.post('/user/email/verify-old', { code: emailForm.code, newEmail: emailForm.newEmail });
        setEmailStep(3);
        setEmailForm(p => ({ ...p, code: '' }));
        toast.success('OTP dikirim ke email baru');
      } else {
        await api.post('/user/email/verify-new', { code: emailForm.code, newEmail: emailForm.newEmail });
        toast.success('Email berhasil diganti! Login ulang.');
        logout();
        router.push('/login');
      }
    } catch (error: any) { toast.error(error.response?.data?.message || 'Gagal'); }
  };

  const handlePhoneChange = async () => {
    try {
      if (phoneStep === 1) {
        const res = await api.post('/user/phone/request', {});
        if (res.data.skipOld) {
          setPhoneStep(3);
        } else {
          setPhoneStep(2);
          toast.success('OTP dikirim ke WhatsApp lama');
        }
      } else if (phoneStep === 2) {
        await api.post('/user/phone/verify-old', { code: phoneForm.code });
        setPhoneStep(3);
        setPhoneForm(p => ({ ...p, code: '' }));
        toast.success('Verifikasi berhasil. Masukkan nomor baru.');
      } else if (phoneStep === 3) {
        await api.post('/user/phone/request-new', { newPhoneNumber: phoneForm.newPhone });
        setPhoneStep(4);
        setPhoneForm(p => ({ ...p, code: '' }));
        toast.success('OTP dikirim ke WhatsApp baru');
      } else {
        await api.post('/user/phone/verify-new', { code: phoneForm.code, newPhoneNumber: phoneForm.newPhone });
        toast.success('Nomor WhatsApp berhasil disimpan!');
        setShowPhone(false);
        fetchProfile();
      }
    } catch (error: any) { toast.error(error.response?.data?.message || 'Gagal'); }
  };

  return (
    <AuthGuard>
      <div className="min-h-screen bg-gray-50 pb-20">
        <Navbar />
        {loading ? (
          <div className="pt-32 text-center text-gray-500">Memuat profil...</div>
        ) : (
          <main className="max-w-4xl mx-auto px-4 pt-24">
            
            <div className="bg-white rounded-3xl p-8 shadow-sm border border-gray-100 flex flex-col md:flex-row items-center gap-8 mb-8">
              <div className="relative">
                <img src={profile?.avatar || `https://ui-avatars.com/api/?name=${profile?.name}`} className="w-32 h-32 rounded-full object-cover border-4 border-gray-50" />
                <button onClick={() => setShowEdit(true)} className="absolute bottom-0 right-0 bg-black text-white p-2 rounded-full hover:bg-gray-800"><Camera size={16}/></button>
              </div>
              <div className="text-center md:text-left flex-1">
                <h1 className="text-3xl font-bold mb-1">{profile?.name}</h1>
                <p className="text-gray-500 mb-4">{profile?.email}</p>
                <div className="flex gap-3 justify-center md:justify-start">
                  <span className="px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-xs font-bold uppercase">{profile?.role}</span>
                  {profile?.isVerified && <span className="px-3 py-1 bg-green-50 text-green-600 rounded-full text-xs font-bold">VERIFIED</span>}
                </div>
              </div>
              <div className="text-center">
                <p className="text-sm text-gray-400 mb-1">Total Belanja</p>
                <p className="text-2xl font-black">Rp {profile?.totalSpent?.toLocaleString('id-ID') || 0}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <h3 className="font-bold mb-4 flex items-center gap-2"><User size={18}/> Informasi Akun</h3>
                <div className="space-y-4">
                  <div className="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
                    <div>
                      <p className="text-xs text-gray-400">Email</p>
                      <p className="font-medium text-sm">{profile?.email}</p>
                    </div>
                    <button onClick={() => setShowEmail(true)} className="text-blue-600 text-xs font-bold hover:underline">Ganti</button>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-gray-50 rounded-xl">
                    <div>
                      <p className="text-xs text-gray-400">No. WhatsApp</p>
                      <p className="font-medium text-sm">{profile?.phoneNumber || '-'}</p>
                    </div>
                    <button onClick={() => { setPhoneStep(1); setShowPhone(true); }} className="text-blue-600 text-xs font-bold hover:underline">
                      {profile?.phoneNumber ? 'Ganti' : 'Hubungkan'}
                    </button>
                  </div>
                </div>
              </div>

              <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <h3 className="font-bold mb-4 flex items-center gap-2"><Lock size={18}/> Keamanan</h3>
                <div className="space-y-4">
                  <button onClick={() => setShowPass(true)} className="w-full flex justify-between items-center p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors text-left">
                    <span className="font-medium text-sm">Ganti Password</span>
                    <Edit size={16} className="text-gray-400"/>
                  </button>
                  <button onClick={logout} className="w-full flex justify-between items-center p-3 bg-red-50 text-red-600 rounded-xl hover:bg-red-100 transition-colors text-left">
                    <span className="font-medium text-sm">Keluar Akun</span>
                    <LogOut size={16}/>
                  </button>
                </div>
              </div>
            </div>

            {showEdit && (
              <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                <div className="bg-white p-6 rounded-2xl w-full max-w-sm">
                  <h3 className="font-bold mb-4">Edit Profil</h3>
                  <div className="flex justify-center mb-4">
                    <div className="relative w-20 h-20">
                      <img src={newAvatar || `https://ui-avatars.com/api/?name=${newName}`} className="w-full h-full rounded-full object-cover border" />
                      <input 
                        type="file" 
                        onChange={(e) => {
                          const file = e.target.files?.[0];
                          if(file) {
                            const reader = new FileReader();
                            reader.onloadend = () => setNewAvatar(reader.result as string);
                            reader.readAsDataURL(file);
                          }
                        }}
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                      />
                    </div>
                  </div>
                  <input value={newName} onChange={e => setNewName(e.target.value)} className="w-full p-3 border rounded-lg mb-3" placeholder="Nama Lengkap" />
                  <div className="flex justify-end gap-2">
                    <button onClick={() => setShowEdit(false)} className="px-4 py-2 bg-gray-100 rounded-lg text-sm">Batal</button>
                    <button onClick={handleUpdateProfile} className="px-4 py-2 bg-black text-white rounded-lg text-sm font-bold">Simpan</button>
                  </div>
                </div>
              </div>
            )}

            {showPass && (
              <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                <div className="bg-white p-6 rounded-2xl w-full max-w-sm shadow-2xl">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="font-bold">Ganti Password</h3>
                    <Link href="/forgot-password" onClick={() => setShowPass(false)} className="text-[10px] font-bold text-accent hover:underline uppercase tracking-wider">Lupa Password?</Link>
                  </div>
                  <input type="password" value={passData.old} onChange={e => setPassData({...passData, old: e.target.value})} className="w-full p-3 border rounded-lg mb-3" placeholder="Password Lama" />
                  <input type="password" value={passData.new} onChange={e => setPassData({...passData, new: e.target.value})} className="w-full p-3 border rounded-lg mb-3" placeholder="Password Baru" />
                  <input type="password" value={passData.confirm} onChange={e => setPassData({...passData, confirm: e.target.value})} className="w-full p-3 border rounded-lg mb-4" placeholder="Konfirmasi Password Baru" />
                  <div className="flex justify-end gap-2">
                    <button onClick={() => setShowPass(false)} className="px-4 py-2 bg-gray-100 rounded-lg text-sm">Batal</button>
                    <button onClick={handleChangePassword} className="px-4 py-2 bg-black text-white rounded-lg text-sm font-bold">Ganti</button>
                  </div>
                </div>
              </div>
            )}

            {showEmail && (
              <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                <div className="bg-white p-6 rounded-2xl w-full max-w-sm">
                  <h3 className="font-bold mb-4">Ganti Email (Tahap {emailStep}/3)</h3>
                  {emailStep === 1 && (
                    <div className="text-center">
                      <p className="text-sm text-gray-500 mb-4">Kami akan mengirim OTP ke email lama Anda ({profile.email}) untuk verifikasi.</p>
                      <button onClick={handleEmailChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Kirim OTP</button>
                    </div>
                  )}
                  {emailStep === 2 && (
                    <>
                      <input value={emailForm.code} onChange={e => setEmailForm({...emailForm, code: e.target.value})} className="w-full p-3 border rounded-lg mb-3 text-center tracking-widest" placeholder="Kode OTP (Email Lama)" />
                      <input value={emailForm.newEmail} onChange={e => setEmailForm({...emailForm, newEmail: e.target.value})} className="w-full p-3 border rounded-lg mb-4" placeholder="Email Baru" />
                      <button onClick={handleEmailChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Lanjut</button>
                    </>
                  )}
                  {emailStep === 3 && (
                    <>
                      <p className="text-sm text-gray-500 mb-2">OTP telah dikirim ke <strong>{emailForm.newEmail}</strong></p>
                      <input value={emailForm.code} onChange={e => setEmailForm({...emailForm, code: e.target.value})} className="w-full p-3 border rounded-lg mb-4 text-center tracking-widest" placeholder="Kode OTP (Email Baru)" />
                      <button onClick={handleEmailChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Verifikasi & Ganti</button>
                    </>
                  )}
                  <button onClick={() => setShowEmail(false)} className="mt-4 text-xs text-gray-400 hover:text-black w-full text-center">Batal</button>
                </div>
              </div>
            )}

            {showPhone && (
              <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                <div className="bg-white p-6 rounded-2xl w-full max-w-sm">
                  <h3 className="font-bold mb-4">Hubungkan WhatsApp</h3>
                  {phoneStep === 1 && (
                    <div className="text-center">
                      <p className="text-sm text-gray-500 mb-4">
                        {profile?.phoneNumber 
                          ? `Kami akan mengirim OTP ke nomor lama (${profile.phoneNumber}) terlebih dahulu.` 
                          : 'Hubungkan nomor WhatsApp untuk keamanan ekstra dan notifikasi.'}
                      </p>
                      <button onClick={handlePhoneChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">
                        {profile?.phoneNumber ? 'Kirim OTP ke Nomor Lama' : 'Mulai Hubungkan'}
                      </button>
                    </div>
                  )}
                  {phoneStep === 2 && (
                    <>
                      <p className="text-sm text-gray-500 mb-2">Masukkan OTP dari WhatsApp lama:</p>
                      <input value={phoneForm.code} onChange={e => setPhoneForm({...phoneForm, code: e.target.value})} className="w-full p-3 border rounded-lg mb-4 text-center tracking-widest" placeholder="Kode OTP" />
                      <button onClick={handlePhoneChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Verifikasi</button>
                    </>
                  )}
                  {phoneStep === 3 && (
                    <>
                      <p className="text-sm text-gray-500 mb-2">Masukkan Nomor WhatsApp Baru (cth: 08123...)</p>
                      <input value={phoneForm.newPhone} onChange={e => setPhoneForm({...phoneForm, newPhone: e.target.value})} className="w-full p-3 border rounded-lg mb-4" placeholder="Nomor WhatsApp" />
                      <button onClick={handlePhoneChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Kirim OTP</button>
                    </>
                  )}
                  {phoneStep === 4 && (
                    <>
                      <p className="text-sm text-gray-500 mb-2">OTP dikirim ke <strong>{phoneForm.newPhone}</strong></p>
                      <input value={phoneForm.code} onChange={e => setPhoneForm({...phoneForm, code: e.target.value})} className="w-full p-3 border rounded-lg mb-4 text-center tracking-widest" placeholder="Kode OTP" />
                      <button onClick={handlePhoneChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Simpan Nomor</button>
                    </>
                  )}
                  <button onClick={() => setShowPhone(false)} className="mt-4 text-xs text-gray-400 hover:text-black w-full text-center">Batal</button>
                </div>
              </div>
            )}

          </main>
        )}
      </div>
    </AuthGuard>
  );
}