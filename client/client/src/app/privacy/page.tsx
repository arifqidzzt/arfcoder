'use client';

import Navbar from '@/components/Navbar';

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white text-gray-800">
      <Navbar />
      <main className="max-w-4xl mx-auto px-8 py-16">
        <h1 className="text-4xl font-bold mb-8">Kebijakan Privasi</h1>
        
        <section className="space-y-6 text-sm leading-relaxed">
          <div>
            <h2 className="text-xl font-bold mb-4">1. Pengumpulan Informasi</h2>
            <p>
              Kami mengumpulkan informasi minimal yang diperlukan untuk memproses pesanan Anda, seperti nama, alamat email, dan detail kontak. Kami tidak menyimpan data kartu kredit atau password bank Anda di server kami.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">2. Penggunaan Data</h2>
            <p>
              Data Anda digunakan semata-mata untuk:
              <ul className="list-disc ml-6 mt-2">
                <li>Memproses pesanan dan pembayaran.</li>
                <li>Mengirimkan update status pesanan.</li>
                <li>Menghubungi Anda terkait dukungan teknis (jika diperlukan).</li>
              </ul>
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">3. Keamanan Data</h2>
            <p>
              Kami menggunakan enkripsi SSL (Secure Socket Layer) untuk melindungi data yang ditransmisikan antara browser Anda dan server kami. 
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">4. Cookies</h2>
            <p>
              Situs ini menggunakan cookies untuk menyimpan sesi login dan konten keranjang belanja Anda guna meningkatkan pengalaman pengguna.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">5. Perubahan Kebijakan</h2>
            <p>
              ArfCoder berhak mengubah kebijakan privasi ini sewaktu-waktu. Perubahan akan segera berlaku setelah dipublikasikan di halaman ini.
            </p>
          </div>
        </section>
      </main>
    </div>
  );
}
