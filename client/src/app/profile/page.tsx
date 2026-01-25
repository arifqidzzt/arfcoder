  const [showPhone, setShowPhone] = useState(false);
  const [phoneStep, setPhoneStep] = useState(1);
  const [phoneForm, setPhoneForm] = useState({ newPhone: '', code: '' });

  // ... (existing handlers)

  const handlePhoneChange = async () => {
    try {
      if (phoneStep === 1) {
        const res = await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/user/phone/request`, {}, { headers: { Authorization: `Bearer ${token}` } });
        if (res.data.skipOld) {
          setPhoneStep(3); // Langsung ke input nomor baru
        } else {
          setPhoneStep(2); // Verifikasi nomor lama
          toast.success('OTP dikirim ke WhatsApp lama');
        }
      } else if (phoneStep === 2) {
        await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/user/phone/verify-old`, { code: phoneForm.code }, { headers: { Authorization: `Bearer ${token}` } });
        setPhoneStep(3);
        setPhoneForm(p => ({ ...p, code: '' }));
        toast.success('Verifikasi berhasil. Masukkan nomor baru.');
      } else if (phoneStep === 3) {
        // Request OTP ke nomor baru
        await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/user/phone/request-new`, { newPhoneNumber: phoneForm.newPhone }, { headers: { Authorization: `Bearer ${token}` } });
        setPhoneStep(4);
        setPhoneForm(p => ({ ...p, code: '' }));
        toast.success('OTP dikirim ke WhatsApp baru');
      } else {
        // Final Verify
        await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/user/phone/verify-new`, { code: phoneForm.code, newPhoneNumber: phoneForm.newPhone }, { headers: { Authorization: `Bearer ${token}` } });
        toast.success('Nomor WhatsApp berhasil disimpan!');
        setShowPhone(false);
        fetchProfile();
      }
    } catch (error: any) { toast.error(error.response?.data?.message || 'Gagal'); }
  };

  if (loading) return <div className="min-h-screen bg-gray-50 pt-24 text-center">Loading...</div>;

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />
      <main className="max-w-4xl mx-auto px-4 pt-24">
        
        {/* ... (Header Profile remains same) ... */}
        {/* INI KODE LAMA, SAYA HANYA TULIS ULANG BAGIAN YANG DIUBAH AGAR REPLACE SUKSES */}
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

        {/* Settings Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Account Info */}
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

          {/* Security */}
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

        {/* MODALS */}
        {/* ... (Edit Profile & Pass Modal same as before) ... */}
        {showEdit && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-2xl w-full max-w-sm">
              <h3 className="font-bold mb-4">Edit Profil</h3>
              <input value={newName} onChange={e => setNewName(e.target.value)} className="w-full p-3 border rounded-lg mb-3" placeholder="Nama Lengkap" />
              <input value={newAvatar} onChange={e => setNewAvatar(e.target.value)} className="w-full p-3 border rounded-lg mb-4" placeholder="URL Foto Profil" />
              <div className="flex justify-end gap-2">
                <button onClick={() => setShowEdit(false)} className="px-4 py-2 bg-gray-100 rounded-lg text-sm">Batal</button>
                <button onClick={handleUpdateProfile} className="px-4 py-2 bg-black text-white rounded-lg text-sm font-bold">Simpan</button>
              </div>
            </div>
          </div>
        )}

        {showPass && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-2xl w-full max-w-sm">
              <h3 className="font-bold mb-4">Ganti Password</h3>
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

        {/* 3. Change Email Modal (Existing) */}
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

        {/* 4. Phone Change Modal (NEW) */}
        {showPhone && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-2xl w-full max-w-sm">
              <h3 className="font-bold mb-4">Hubungkan WhatsApp</h3>
              
              {/* Step 1: Request Old */}
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

              {/* Step 2: Verify Old */}
              {phoneStep === 2 && (
                <>
                  <p className="text-sm text-gray-500 mb-2">Masukkan OTP dari WhatsApp lama:</p>
                  <input value={phoneForm.code} onChange={e => setPhoneForm({...phoneForm, code: e.target.value})} className="w-full p-3 border rounded-lg mb-4 text-center tracking-widest" placeholder="Kode OTP" />
                  <button onClick={handlePhoneChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Verifikasi</button>
                </>
              )}

              {/* Step 3: Input New Number */}
              {phoneStep === 3 && (
                <>
                  <p className="text-sm text-gray-500 mb-2">Masukkan Nomor WhatsApp Baru (cth: 08123...)</p>
                  <input value={phoneForm.newPhone} onChange={e => setPhoneForm({...phoneForm, newPhone: e.target.value})} className="w-full p-3 border rounded-lg mb-4" placeholder="Nomor WhatsApp" />
                  <button onClick={handlePhoneChange} className="w-full py-2 bg-black text-white rounded-lg font-bold">Kirim OTP</button>
                </>
              )}

              {/* Step 4: Verify New */}
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
    </div>
  );
}
