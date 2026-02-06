'use client';

import Navbar from '@/components/Navbar';

export default function RefundPolicyPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="text-center mb-20">
          <div className="inline-flex items-center gap-2 px-3 py-1 bg-red-50 text-red-600 rounded-full text-[10px] font-black uppercase tracking-widest mb-4">
            Refund Policy
          </div>
          <h1 className="text-4xl md:text-6xl font-black tracking-tighter mb-4 italic">Kebijakan <span className="text-gradient">Refund</span></h1>
          <p className="text-gray-500 font-medium italic">Aturan pengembalian dana untuk produk digital kami.</p>
        </div>
        
        <section className="space-y-8">
          {[
            { title: "1. Sifat Produk Digital", content: "ArfCoder menyediakan produk digital berupa template koding, perangkat lunak, dan aset desain. Karena sifat produk digital yang dapat disalin dan digunakan secara instan setelah akses diberikan, maka semua pembelian bersifat final." },
            { title: "2. Pengecualian Refund", content: "Refund hanya akan dipertimbangkan jika terjadi transaksi ganda akibat kesalahan sistem, produk yang dikirimkan terbukti rusak/corrupt secara teknis, atau jasa custom belum dikerjakan sama sekali melewati batas waktu yang dijanjikan." },
            { title: "3. Batas Waktu Pengajuan", content: "Segala bentuk keluhan atau pengajuan refund harus disampaikan maksimal dalam waktu 24 jam setelah transaksi dilakukan melalui kontak resmi kami untuk dapat diproses." },
            { title: "4. Proses Pengembalian", content: "Jika pengajuan disetujui, dana akan dikembalikan melalui mekanisme asli pembayaran atau transfer bank manual dalam waktu 7-14 hari kerja." }
          ].map((item, i) => (
            <div key={i} className="p-8 rounded-[2rem] bg-gray-50 border border-gray-100">
              <h2 className="text-xl font-black mb-4 flex items-center gap-3">
                <span className="text-accent">/0{i+1}</span>
                {item.title}
              </h2>
              <p className="text-gray-600 leading-relaxed font-medium italic pl-10">
                {item.content}
              </p>
            </div>
          ))}

          <div className="p-10 bg-accent/5 rounded-[2.5rem] border border-accent/10 italic mt-12 text-center text-gray-700 font-bold">
            "Dengan melakukan pembelian di arfzxdev.com, pelanggan dianggap telah membaca, memahami, dan menyetujui kebijakan pengembalian dana ini tanpa paksaan."
          </div>
        </section>
      </main>
    </div>
  );
}
