'use client';

import Navbar from '@/components/Navbar';
import { useState } from 'react';
import { ChevronDown, ChevronUp, MessageCircle } from 'lucide-react';

export default function FAQPage() {
  const faqs = [
    {
      question: "Bagaimana cara melakukan pembelian produk digital?",
      answer: "Pilih produk yang Anda inginkan, klik 'Tambah ke Keranjang', lalu lanjutkan ke Checkout. Setelah pembayaran berhasil, akses produk akan muncul secara otomatis di menu 'Pesanan Saya'."
    },
    {
      question: "Metode pembayaran apa saja yang tersedia?",
      answer: "Kami menerima pembayaran melalui QRIS (Gopay, ShopeePay, Dana), Virtual Account (BCA, Mandiri, BNI, BRI) melalui sistem Midtrans yang aman dan terenkripsi."
    },
    {
      question: "Berapa lama proses pengerjaan jasa website?",
      answer: "Waktu pengerjaan bervariasi. Company Profile biasanya 3-7 hari, sedangkan aplikasi custom atau Toko Online bisa memakan waktu 2-4 minggu tergantung fitur."
    },
    {
      question: "Apakah ada garansi setelah website selesai?",
      answer: "Ya, kami memberikan garansi perbaikan bug gratis selama 1 bulan setelah proyek diserahterimakan untuk memastikan semuanya berjalan lancar."
    }
  ];

  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="text-center mb-20">
          <div className="inline-flex items-center gap-2 px-3 py-1 bg-gray-100 rounded-full text-[10px] font-black uppercase tracking-widest mb-4">
            Help Center
          </div>
          <h1 className="text-4xl md:text-6xl font-black tracking-tighter mb-4 italic">Pertanyaan <span className="text-gradient">Umum</span></h1>
          <p className="text-gray-500 font-medium italic">Temukan jawaban cepat untuk keraguan Anda.</p>
        </div>

        <div className="space-y-6">
          {faqs.map((faq, index) => (
            <div 
              key={index} 
              className={`rounded-[2.5rem] border transition-all duration-500 overflow-hidden ${
                openIndex === index ? 'bg-black text-white border-black shadow-2xl scale-[1.02]' : 'bg-gray-50 text-gray-900 border-gray-100 hover:border-accent/20'
              }`}
            >
              <button 
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full px-10 py-8 flex justify-between items-center text-left focus:outline-none"
              >
                <span className="font-black text-xl tracking-tight italic">
                  {faq.question}
                </span>
                <div className={`w-10 h-10 rounded-full flex items-center justify-center transition-all duration-500 ${
                  openIndex === index ? 'bg-accent text-white rotate-180' : 'bg-white text-gray-400'
                }`}>
                  <ChevronDown size={20} />
                </div>
              </button>
              
              <div 
                className={`px-10 overflow-hidden transition-all duration-500 ${
                  openIndex === index ? 'max-h-96 pb-10 opacity-100' : 'max-h-0 opacity-0'
                }`}
              >
                <p className={`leading-relaxed font-medium italic ${openIndex === index ? 'text-gray-300' : 'text-gray-500'}`}>
                  {faq.answer}
                </p>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-24 p-12 rounded-[3.5rem] bg-secondary/30 border border-border text-center">
          <h3 className="text-3xl font-black mb-4">Masih butuh bantuan?</h3>
          <p className="text-gray-500 mb-10 font-medium italic">Tim support kami siap membantu Anda 24/7 melalui WhatsApp atau Email.</p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="https://wa.me/628988289551" className="bg-black text-white px-10 py-5 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-accent transition-all flex items-center justify-center gap-2">
              <MessageCircle size={18} /> Chat WhatsApp
            </a>
            <a href="/contact" className="bg-white border border-border text-black px-10 py-5 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-gray-50 transition-all flex items-center justify-center gap-2">
              Email Support
            </a>
          </div>
        </div>
      </main>
    </div>
  );
}
