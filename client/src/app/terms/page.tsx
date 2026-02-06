'use client';

import Navbar from '@/components/Navbar';

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="text-center mb-20">
          <div className="inline-flex items-center gap-2 px-3 py-1 bg-gray-100 rounded-full text-[10px] font-black uppercase tracking-widest mb-4">
            Legal Document
          </div>
          <h1 className="text-4xl md:text-6xl font-black tracking-tighter mb-4 italic">Syarat & <span className="text-gradient">Ketentuan</span></h1>
          <p className="text-gray-500 font-medium italic">Terakhir diperbarui: 6 Februari 2026</p>
        </div>
        
        <section className="space-y-12">
          {[
            { title: "1. Informasi Umum", content: "Selamat datang di ArfCoder (arfzxdev.com). Dengan mengakses dan menggunakan situs web ini, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Jika Anda tidak setuju, mohon untuk tidak menggunakan layanan kami." },
            { title: "2. Layanan Kami", content: "ArfCoder menyediakan produk digital berupa template koding, aset desain, dan jasa pengembangan perangkat lunak (website dan aplikasi mobile)." },
            { title: "3. Proses Pembelian", content: "Semua transaksi dilakukan melalui sistem pembayaran resmi (Midtrans). Pelanggan wajib memberikan data yang akurat untuk keperluan pengiriman produk digital atau koordinasi jasa digital." },
            { title: "4. Kebijakan Refund", content: "Karena sifat produk kami adalah aset digital yang dapat disalin secara instan, kami tidak menyediakan pengembalian dana setelah produk berhasil diunduh atau akses diberikan, kecuali terjadi kesalahan teknis permanen dari pihak kami." },
            { title: "5. Keamanan Transaksi", content: "Kami berkomitmen untuk menjaga keamanan data transaksi Anda. Semua data pembayaran diproses oleh Midtrans sesuai dengan standar industri keamanan data (PCI-DSS)." }
          ].map((item, i) => (
            <div key={i} className="group">
              <h2 className="text-2xl font-black mb-4 flex items-center gap-4 group-hover:text-accent transition-colors">
                <span className="w-8 h-8 rounded-lg bg-black text-white flex items-center justify-center text-xs">{i+1}</span>
                {item.title}
              </h2>
              <div className="pl-12">
                <p className="text-gray-600 leading-relaxed font-medium italic">
                  {item.content}
                </p>
              </div>
            </div>
          ))}

          <div className="mt-20 p-10 bg-secondary/30 rounded-[2.5rem] border border-border">
            <h2 className="text-2xl font-black mb-6">6. Kontak Kami</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-sm">
              <div className="flex flex-col gap-2">
                <span className="font-black uppercase tracking-widest text-gray-400 text-[10px]">Email</span>
                <p className="font-bold">arfzxcoder@gmail.com</p>
              </div>
              <div className="flex flex-col gap-2">
                <span className="font-black uppercase tracking-widest text-gray-400 text-[10px]">WhatsApp</span>
                <p className="font-bold">08988289551</p>
              </div>
              <div className="col-span-full flex flex-col gap-2">
                <span className="font-black uppercase tracking-widest text-gray-400 text-[10px]">Alamat</span>
                <p className="font-bold italic">Jl.Kebun Baru Indah Blok Puhun Dusun 4 Kabupaten Cirebon</p>
              </div>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
