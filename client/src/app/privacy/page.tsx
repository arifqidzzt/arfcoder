'use client';

import Navbar from '@/components/Navbar';

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="text-center mb-20">
          <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-[10px] font-black uppercase tracking-widest mb-4">
            Privacy Matters
          </div>
          <h1 className="text-4xl md:text-6xl font-black tracking-tighter mb-4 italic">Kebijakan <span className="text-gradient">Privasi</span></h1>
          <p className="text-gray-500 font-medium italic">Bagaimana kami melindungi data Anda.</p>
        </div>
        
        <section className="space-y-8">
          {[
            { title: "1. Pengumpulan Informasi", content: "Kami mengumpulkan informasi minimal yang diperlukan untuk memproses pesanan Anda, seperti nama, alamat email, dan detail kontak. Kami tidak menyimpan data kartu kredit atau password bank Anda di server kami." },
            { title: "2. Penggunaan Data", content: "Data Anda digunakan semata-mata untuk memproses pesanan, mengirimkan update status, dan memberikan dukungan teknis jika diperlukan. Kami tidak akan menjual data Anda ke pihak ketiga." },
            { title: "3. Keamanan Data", content: "Kami menggunakan enkripsi SSL (Secure Socket Layer) standar industri untuk melindungi setiap data yang ditransmisikan antara perangkat Anda dan server kami." },
            { title: "4. Cookies", content: "Situs ini menggunakan cookies teknis untuk menyimpan sesi login dan isi keranjang belanja Anda guna memberikan pengalaman pengguna yang lebih lancar." },
            { title: "5. Perubahan Kebijakan", content: "ArfCoder berhak mengubah kebijakan privasi ini sewaktu-waktu. Setiap perubahan akan diumumkan secara transparan melalui halaman ini." }
          ].map((item, i) => (
            <div key={i} className="p-8 rounded-[2rem] bg-gray-50 border border-gray-100 hover:border-accent/20 transition-all">
              <h2 className="text-xl font-black mb-4 flex items-center gap-3">
                <span className="text-accent">0{i+1}.</span>
                {item.title}
              </h2>
              <p className="text-gray-600 leading-relaxed font-medium italic pl-8">
                {item.content}
              </p>
            </div>
          ))}
        </section>

        <div className="mt-20 p-12 bg-black rounded-[3rem] text-white text-center relative overflow-hidden">
          <div className="absolute top-0 right-0 w-32 h-32 bg-accent/20 rounded-full blur-3xl" />
          <h3 className="text-2xl font-black mb-4 relative z-10">Punya pertanyaan tentang privasi?</h3>
          <p className="text-gray-400 mb-8 relative z-10 italic">Tim kami siap menjelaskan bagaimana kami menjaga keamanan data Anda.</p>
          <a href="/contact" className="px-10 py-4 bg-white text-black rounded-xl font-black text-xs uppercase tracking-widest hover:bg-accent hover:text-white transition-all relative z-10 inline-block">
            Hubungi Tim Kami
          </a>
        </div>
      </main>
    </div>
  );
}
