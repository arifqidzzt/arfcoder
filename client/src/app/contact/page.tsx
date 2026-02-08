'use client';

import Navbar from '@/components/Navbar';
import { Mail, Smartphone, MessageSquare, AlertTriangle, ShieldCheck, Clock, Zap } from 'lucide-react';

export default function ContactSalesPage() {
  const email = "arfcoder@gmail.com";
  const phone = "628988289551";

  const handleEmail = () => {
    const subject = encodeURIComponent("Permintaan Layanan/Produk ArfCoder");
    const body = encodeURIComponent("Halo Tim Sales ArfCoder,\n\nSaya tertarik untuk mengetahui lebih lanjut mengenai [Nama Produk/Jasa]. Berikut adalah rincian kebutuhan saya:\n\n...");
    window.open(`mailto:${email}?subject=${subject}&body=${body}`, '_blank');
  };

  const handleWA = () => {
    const text = encodeURIComponent("Halo Tim Sales ArfCoder, saya ingin berkonsultasi mengenai kebutuhan digital bisnis saya.");
    window.open(`https://wa.me/${phone}?text=${text}`, '_blank');
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />
      <main className="max-w-6xl mx-auto px-4 pt-32">
        <div className="text-center mb-16" data-aos="fade-up">
          <span className="text-accent font-bold tracking-wider uppercase text-sm mb-2 block">Konsultasi Gratis</span>
          <h1 className="text-5xl font-bold mb-4 tracking-tight">Hubungi Tim Sales</h1>
          <p className="text-gray-500 max-w-2xl mx-auto text-lg leading-relaxed">
            Siap untuk memulai transformasi digital Anda? Tim sales kami siap membantu memberikan solusi terbaik untuk bisnis Anda.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-20">
          {/* Email Card */}
          <div onClick={handleEmail} data-aos="fade-up" data-aos-delay="100" className="bg-white p-10 rounded-3xl shadow-sm border border-gray-100 hover:shadow-xl transition-all cursor-pointer group relative overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-blue-500/5 rounded-full -mr-8 -mt-8 group-hover:scale-150 transition-transform duration-500" />
            <div className="w-16 h-16 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 transition-transform">
              <Mail size={32} />
            </div>
            <h3 className="font-bold text-xl mb-3">Respon via Email</h3>
            <p className="text-sm text-gray-400 mb-6">Cocok untuk penawaran resmi dan rincian teknis yang kompleks.</p>
            <p className="text-blue-600 font-bold text-sm inline-flex items-center gap-2">
              Kirim Email <span className="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </p>
          </div>

          {/* WhatsApp Card */}
          <div onClick={handleWA} data-aos="fade-up" data-aos-delay="200" className="bg-white p-10 rounded-3xl shadow-sm border border-gray-100 hover:shadow-xl transition-all cursor-pointer group relative overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-green-500/5 rounded-full -mr-8 -mt-8 group-hover:scale-150 transition-transform duration-500" />
            <div className="w-16 h-16 bg-green-50 text-green-600 rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 transition-transform">
              <Smartphone size={32} />
            </div>
            <h3 className="font-bold text-xl mb-3">Respon Cepat WA</h3>
            <p className="text-sm text-gray-400 mb-6">Konsultasi instan dengan tim kami selama jam kerja operasional.</p>
            <p className="text-green-600 font-bold text-sm inline-flex items-center gap-2">
              Chat Sekarang <span className="group-hover:translate-x-1 transition-transform">&rarr;</span>
            </p>
          </div>

          {/* Live Chat Card */}
          <div data-aos="fade-up" data-aos-delay="300" className="bg-white p-10 rounded-3xl shadow-sm border border-gray-100 opacity-70 relative overflow-hidden grayscale">
            <div className="w-16 h-16 bg-gray-100 text-gray-400 rounded-2xl flex items-center justify-center mb-8">
              <MessageSquare size={32} />
            </div>
            <h3 className="font-bold text-xl mb-3 text-gray-400">Live Chat Web</h3>
            <div className="flex items-center gap-2 text-yellow-600 text-[10px] font-black bg-yellow-50 py-1 px-3 rounded-full w-fit mb-4">
              <AlertTriangle size={12} /> UNDER MAINTENANCE
            </div>
            <p className="text-xs text-gray-400">Kami sedang meningkatkan infrastruktur chat kami untuk melayani Anda lebih baik.</p>
          </div>
        </div>

        {/* Why Contact Us */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-12 text-left bg-black text-white p-12 rounded-[40px] shadow-2xl">
          <div className="space-y-4">
            <div className="w-12 h-12 bg-white/10 rounded-xl flex items-center justify-center text-accent">
              <Clock size={24} />
            </div>
            <h4 className="font-bold text-lg">Respon Cepat</h4>
            <p className="text-sm text-gray-400 leading-relaxed">Tim kami berkomitmen memberikan respon dalam waktu kurang dari 2 jam pada jam kerja.</p>
          </div>
          <div className="space-y-4">
            <div className="w-12 h-12 bg-white/10 rounded-xl flex items-center justify-center text-accent">
              <ShieldCheck size={24} />
            </div>
            <h4 className="font-bold text-lg">Konsultasi Gratis</h4>
            <p className="text-sm text-gray-400 leading-relaxed">Tidak ada biaya untuk diskusi awal mengenai kebutuhan atau ide proyek digital Anda.</p>
          </div>
          <div className="space-y-4">
            <div className="w-12 h-12 bg-white/10 rounded-xl flex items-center justify-center text-accent">
              <Zap size={24} />
            </div>
            <h4 className="font-bold text-lg">Solusi Tepat</h4>
            <p className="text-sm text-gray-400 leading-relaxed">Kami tidak hanya menjual, tapi memberikan solusi teknologi yang paling efisien untuk Anda.</p>
          </div>
        </div>
      </main>
    </div>
  );
}