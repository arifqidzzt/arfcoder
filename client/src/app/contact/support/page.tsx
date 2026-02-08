'use client';

import Navbar from '@/components/Navbar';
import { Mail, Smartphone, MessageSquare, AlertTriangle, LifeBuoy } from 'lucide-react';

export default function ContactSupportPage() {
  const email = "arfcoder@gmail.com";
  const phone = "628988289551";

  const handleEmail = () => {
    const subject = encodeURIComponent("Bantuan Teknis ArfCoder");
    const body = encodeURIComponent("Halo Tim Support ArfCoder,\n\nSaya mengalami kendala pada akun/pesanan saya:\n\n[Jelaskan Masalah Anda Disini]\n\nMohon bantuannya.");
    window.open(`mailto:${email}?subject=${subject}&body=${body}`, '_blank');
  };

  const handleWA = () => {
    const text = encodeURIComponent("Halo Admin Support, saya butuh bantuan terkait masalah teknis di website.");
    window.open(`https://wa.me/${phone}?text=${text}`, '_blank');
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />
      <main className="max-w-6xl mx-auto px-4 pt-32">
        <div className="text-center mb-16">
          <span className="text-blue-600 font-bold tracking-wider uppercase text-sm mb-2 block">Customer Service</span>
          <h1 className="text-5xl font-bold mb-4 tracking-tight">Hubungi Support</h1>
          <p className="text-gray-500 max-w-2xl mx-auto text-lg leading-relaxed">
            Mengalami kendala teknis atau masalah pesanan? Tim support kami siap membantu Anda menyelesaikan masalah secepat mungkin.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-20">
          {/* Email Card */}
          <div onClick={handleEmail} className="bg-white p-10 rounded-3xl shadow-sm border border-gray-100 hover:shadow-xl transition-all cursor-pointer group relative overflow-hidden">
            <div className="w-16 h-16 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 transition-transform">
              <Mail size={32} />
            </div>
            <h3 className="font-bold text-xl mb-3">Email Support</h3>
            <p className="text-sm text-gray-400 mb-6">Kirim detail masalah Anda beserta screenshot jika ada.</p>
            <p className="text-blue-600 font-bold text-sm inline-flex items-center gap-2">
              Kirim Tiket <span className="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </p>
          </div>

          {/* WhatsApp Card */}
          <div onClick={handleWA} className="bg-white p-10 rounded-3xl shadow-sm border border-gray-100 hover:shadow-xl transition-all cursor-pointer group relative overflow-hidden">
            <div className="w-16 h-16 bg-green-50 text-green-600 rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 transition-transform">
              <Smartphone size={32} />
            </div>
            <h3 className="font-bold text-xl mb-3">Chat Support WA</h3>
            <p className="text-sm text-gray-400 mb-6">Bantuan langsung untuk masalah mendesak.</p>
            <p className="text-green-600 font-bold text-sm inline-flex items-center gap-2">
              Chat Support <span className="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </p>
          </div>

          {/* Live Chat Card */}
          <div className="bg-white p-10 rounded-3xl shadow-sm border border-gray-100 opacity-70 relative overflow-hidden grayscale">
            <div className="w-16 h-16 bg-gray-100 text-gray-400 rounded-2xl flex items-center justify-center mb-8">
              <LifeBuoy size={32} />
            </div>
            <h3 className="font-bold text-xl mb-3 text-gray-400">Help Center</h3>
            <div className="flex items-center gap-2 text-yellow-600 text-[10px] font-black bg-yellow-50 py-1 px-3 rounded-full w-fit mb-4">
              <AlertTriangle size={12} /> MAINTENANCE
            </div>
            <p className="text-xs text-gray-400">Sistem tiket live chat sedang dalam pemeliharaan.</p>
          </div>
        </div>
      </main>
    </div>
  );
}
