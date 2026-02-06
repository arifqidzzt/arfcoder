'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '@/lib/api';
import { User, Mail, Phone, Lock, Edit, Camera, LogOut } from 'lucide-react';
import toast from 'react-hot-toast';
import AuthGuard from '@/components/AuthGuard';
import { useTranslation } from '@/lib/i18n';

export default function ProfilePage() {
  const { user, logout, login } = useAuthStore();
  const { t } = useTranslation();
  const router = useRouter();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  
  const [showEdit, setShowEdit] = useState(false);
  const [showPass, setShowPass] = useState(false);
  const [showEmail, setShowEmail] = useState(false);
  const [showPhone, setShowPhone] = useState(false);
  
  const [newName, setNewName] = useState('');
  const [newAvatar, setNewAvatar] = useState('');
  const [passData, setPassData] = useState({ old: '', new: '', confirm: '' });
  const [emailStep, setEmailStep] = useState(1);
  const [emailForm, setEmailForm] = useState({ newEmail: '', code: '' });
  const [phoneStep, setPhoneStep] = useState(1);
  const [phoneForm, setPhoneForm] = useState({ newPhone: '', code: '' });

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const res = await api.get('/user/profile');
      setProfile(res.data);
      setNewName(res.data.name);
      setNewAvatar(res.data.avatar || '');
    } catch (error) { toast.error('Failed'); } finally { setLoading(false); }
  };

  const handleUpdateProfile = async () => {
    try {
      await api.put('/user/profile', { name: newName, avatar: newAvatar });
      toast.success(t('common.success'));
      setShowEdit(false);
      fetchProfile();
    } catch (error) { toast.error('Error'); }
  };

  return (
    <AuthGuard>
      <div className="min-h-screen bg-gray-50 pb-20">
        <Navbar />
        {loading ? (
          <div className="pt-32 text-center text-gray-500">{t('common.loading')}</div>
        ) : (
          <main className="max-w-4xl mx-auto px-4 pt-24">
            
            <div className="bg-white rounded-3xl p-8 shadow-sm border border-gray-100 flex flex-col md:flex-row items-center gap-8 mb-8">
              <div className="relative">
                <img src={profile?.avatar || `https://ui-avatars.com/api/?name=${profile?.name}`} className="w-32 h-32 rounded-full object-cover border-4 border-gray-50" />
                <button onClick={() => setShowEdit(true)} className="absolute bottom-0 right-0 bg-black text-white p-2 rounded-full"><Camera size={16}/></button>
              </div>
              <div className="text-center md:text-left flex-1">
                <h1 className="text-3xl font-bold mb-1">{profile?.name}</h1>
                <p className="text-gray-500 mb-4">{profile?.email}</p>
                <div className="flex gap-3 justify-center md:justify-start">
                  <span className="px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-xs font-bold uppercase">{profile?.role}</span>
                  {profile?.isVerified && <span className="px-3 py-1 bg-green-50 text-green-600 rounded-full text-xs font-bold uppercase">{t('profile.verified')}</span>}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
                <h3 className="font-bold mb-4 flex items-center gap-2"><User size={18}/> {t('profile.title')}</h3>
                <div className="space-y-4">
                  <div className="p-3 bg-gray-50 rounded-xl flex justify-between items-center">
                    <div><p className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">{t('auth.email')}</p><p className="font-medium text-sm">{profile?.email}</p></div>
                    <button onClick={() => setShowEmail(true)} className="text-blue-600 text-xs font-bold">{t('profile.edit')}</button>
                  </div>
                  <div className="p-3 bg-gray-50 rounded-xl flex justify-between items-center">
                    <div><p className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">{t('profile.phone')}</p><p className="font-medium text-sm">{profile?.phoneNumber || '-'}</p></div>
                    <button onClick={() => setShowPhone(true)} className="text-blue-600 text-xs font-bold">{t('profile.edit')}</button>
                  </div>
                </div>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
                <h3 className="font-bold mb-4 flex items-center gap-2"><Lock size={18}/> {t('profile.security')}</h3>
                <div className="space-y-4">
                  <button onClick={() => setShowPass(true)} className="w-full flex justify-between p-3 bg-gray-50 rounded-xl text-sm font-bold">{t('profile.change_pass')} <Edit size={16}/></button>
                  <button onClick={logout} className="w-full flex justify-between p-3 bg-red-50 text-red-600 rounded-xl text-sm font-bold">{t('navbar.logout')} <LogOut size={16}/></button>
                </div>
              </div>
            </div>
          </main>
        )}
      </div>
    </AuthGuard>
  );
}
