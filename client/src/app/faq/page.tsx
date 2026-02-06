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
      <main className="max-w-3xl mx-auto px-6 py-24 md:py-32">
        <div className="mb-16 border-b pb-8">
          <h1 className="text-3xl md:text-4xl font-black tracking-tight mb-2 italic">Pertanyaan Umum <span className="text-gradient">(FAQ)</span></h1>
          <p className="text-gray-500 font-medium italic">Temukan jawaban cepat untuk keraguan Anda.</p>
        </div>

        <div className="space-y-2">
          {faqs.map((faq, index) => (
            <div key={index} className="border-b border-gray-100 last:border-0">
              <button 
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full py-6 flex justify-between items-center text-left focus:outline-none group"
              >
                <span className={`font-bold transition-colors italic ${openIndex === index ? 'text-accent' : 'text-gray-700 group-hover:text-black'}`}>
                  {faq.question}
                </span>
                <ChevronDown className={`text-gray-400 transition-transform duration-300 ${openIndex === index ? 'rotate-180 text-accent' : ''}`} size={18} />
              </button>
              
              <div 
                className={`overflow-hidden transition-all duration-300 ${
                  openIndex === index ? 'max-h-48 pb-6 opacity-100' : 'max-h-0 opacity-0'
                }`}
              >
                <p className="text-gray-500 text-sm leading-relaxed italic">
                  {faq.answer}
                </p>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-20 p-10 bg-gray-50 rounded-3xl text-center border border-gray-100">
          <h3 className="text-xl font-bold mb-2">Masih butuh bantuan?</h3>
          <p className="text-sm text-gray-500 mb-8 italic">Tim support kami siap membantu Anda melalui WhatsApp atau Email.</p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="https://wa.me/628988289551" className="bg-black text-white px-8 py-3 rounded-xl font-bold text-[10px] uppercase tracking-widest hover:bg-accent transition-all flex items-center justify-center gap-2">
              <MessageCircle size={16} /> WhatsApp Support
            </a>
          </div>
        </div>
      </main>
    </div>
  );
}
