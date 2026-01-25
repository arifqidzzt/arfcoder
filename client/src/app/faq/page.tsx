'use client';

import Navbar from '@/components/Navbar';
import { useState } from 'react';
import { ChevronDown, ChevronUp, MessageCircle } from 'lucide-react';

export default function FAQPage() {
  const faqs = [
    {
      question: "Bagaimana cara melakukan pembelian produk digital?",
      answer: "Pilih produk yang Anda inginkan, klik 'Tambah ke Keranjang', lalu lanjutkan ke Checkout. Setelah pembayaran berhasil dikonfirmasi oleh sistem, Anda akan mendapatkan link download atau akses produk di menu 'Pesanan Saya'."
    },
    {
      question: "Metode pembayaran apa saja yang tersedia?",
      answer: "Kami menerima pembayaran melalui QRIS (Gopay, ShopeePay, Dana), Virtual Account (BCA, Mandiri, BNI, BRI), dan kartu kredit melalui payment gateway Midtrans yang aman."
    },
    {
      question: "Apakah saya bisa meminta refund?",
      answer: "Refund hanya dapat dilakukan jika produk digital yang diterima rusak atau tidak sesuai deskripsi fatal. Silakan ajukan refund melalui menu 'Pesanan Saya' maksimal 24 jam setelah pembelian. Cek halaman Kebijakan Refund untuk detail lengkap."
    },
    {
      question: "Berapa lama proses pengerjaan jasa pembuatan website?",
      answer: "Waktu pengerjaan bervariasi tergantung kompleksitas proyek. Untuk website Company Profile biasanya 3-7 hari kerja, sedangkan untuk Toko Online atau Web App custom bisa memakan waktu 2-4 minggu."
    },
    {
      question: "Apakah ada garansi setelah website selesai dibuat?",
      answer: "Ya, kami memberikan garansi maintenance gratis selama 1 bulan setelah website diserahterimakan untuk perbaikan bug minor. Untuk update fitur baru, akan dikenakan biaya tambahan."
    },
    {
      question: "Bagaimana jika saya lupa password akun saya?",
      answer: "Anda dapat menggunakan fitur 'Lupa Password' di halaman login. Kami akan mengirimkan link verifikasi untuk mengatur ulang password baru Anda melalui email terdaftar."
    }
  ];

  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <main className="max-w-3xl mx-auto px-8 py-24">
        <div className="text-center mb-16">
          <span className="text-accent font-bold tracking-wider uppercase text-sm mb-2 block">Pusat Bantuan</span>
          <h1 className="text-4xl font-bold mb-4">Pertanyaan Umum (FAQ)</h1>
          <p className="text-gray-500">Temukan jawaban cepat untuk pertanyaan Anda di sini.</p>
        </div>

        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <div 
              key={index} 
              className="bg-white rounded-2xl border border-gray-200 overflow-hidden transition-all duration-300 hover:shadow-md"
            >
              <button 
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full px-6 py-5 flex justify-between items-center text-left focus:outline-none"
              >
                <span className={`font-bold text-lg ${openIndex === index ? 'text-black' : 'text-gray-600'}`}>
                  {faq.question}
                </span>
                {openIndex === index ? (
                  <ChevronUp className="text-accent" />
                ) : (
                  <ChevronDown className="text-gray-400" />
                )}
              </button>
              
              <div 
                className={`px-6 overflow-hidden transition-all duration-300 ${
                  openIndex === index ? 'max-h-96 pb-6 opacity-100' : 'max-h-0 opacity-0'
                }`}
              >
                <p className="text-gray-500 leading-relaxed">
                  {faq.answer}
                </p>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-16 text-center bg-blue-50 p-8 rounded-3xl border border-blue-100">
          <h3 className="font-bold text-xl mb-2">Masih butuh bantuan?</h3>
          <p className="text-gray-500 mb-6">Tim support kami siap membantu Anda 24/7.</p>
          <a href="/contact" className="bg-black text-white px-8 py-3 rounded-xl font-bold hover:bg-gray-800 transition-colors inline-flex items-center gap-2">
            <MessageCircle size={18} /> Hubungi Kami
          </a>
        </div>
      </main>
    </div>
  );
}
