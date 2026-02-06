'use client';

import Navbar from '@/components/Navbar';

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="mb-16 border-b pb-8">
          <h1 className="text-3xl md:text-4xl font-black tracking-tight mb-4">Kebijakan Privasi</h1>
          <p className="text-gray-500 text-sm italic">Terakhir diperbarui: 6 Februari 2026</p>
        </div>
        
        <div className="prose prose-gray max-w-none space-y-12">
          <section>
            <h2 className="text-xl font-bold mb-4 text-black">1. Pengumpulan Informasi</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Kami mengumpulkan informasi minimal yang diperlukan untuk memproses pesanan Anda, seperti nama, alamat email, dan detail kontak. Kami tidak menyimpan data kartu kredit atau password bank Anda di server kami.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">2. Penggunaan Data</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Data Anda digunakan semata-mata untuk memproses pesanan, mengirimkan update status pesanan, dan menghubungi Anda terkait dukungan teknis jika diperlukan.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">3. Keamanan Data</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Kami menggunakan enkripsi SSL (Secure Socket Layer) untuk melindungi data yang ditransmisikan antara browser Anda dan server kami sesuai dengan standar keamanan industri.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">4. Cookies</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Situs ini menggunakan cookies teknis untuk menyimpan sesi login dan konten keranjang belanja Anda guna memberikan pengalaman pengguna yang lebih lancar.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">5. Perubahan Kebijakan</h2>
            <p className="text-gray-600 leading-relaxed italic">
              ArfCoder berhak mengubah kebijakan privasi ini sewaktu-waktu. Perubahan akan segera berlaku setelah dipublikasikan di halaman ini untuk menjaga transparansi kepada pelanggan.
            </p>
          </section>
        </div>
      </main>
    </div>
  );
}
