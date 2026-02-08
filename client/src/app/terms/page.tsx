'use client';

import Navbar from '@/components/Navbar';

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="mb-16 border-b pb-8">
          <h1 className="text-3xl md:text-4xl font-black tracking-tight mb-4">Syarat & Ketentuan</h1>
          <p className="text-gray-500 text-sm italic">Terakhir diperbarui: 6 Februari 2026</p>
        </div>

        <div className="prose prose-gray max-w-none space-y-12">
          <section>
            <h2 className="text-xl font-bold mb-4 text-black">1. Informasi Umum</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Selamat datang di ArfCoder (arfzxdev.com). Dengan mengakses dan menggunakan situs web ini, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Jika Anda tidak setuju, mohon untuk tidak menggunakan layanan kami.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">2. Layanan Kami</h2>
            <p className="text-gray-600 leading-relaxed italic">
              ArfCoder menyediakan produk digital berupa template koding, aset desain, dan jasa pengembangan perangkat lunak (website dan aplikasi mobile).
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">3. Proses Pembelian</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Semua transaksi dilakukan melalui sistem pembayaran resmi (Midtrans). Pelanggan wajib memberikan data yang akurat untuk keperluan pengiriman produk digital atau koordinasi jasa digital.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">4. Kebijakan Refund</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Karena sifat produk kami adalah aset digital yang dapat disalin secara instan, kami tidak menyediakan pengembalian dana setelah produk berhasil diunduh atau akses diberikan, kecuali terjadi kesalahan teknis permanen dari pihak kami.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">5. Keamanan Transaksi</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Kami berkomitmen untuk menjaga keamanan data transaksi Anda. Semua data pembayaran diproses oleh Midtrans sesuai dengan standar industri keamanan data (PCI-DSS).
            </p>
          </section>

          <section className="pt-8 border-t">
            <h2 className="text-xl font-bold mb-4 text-black">6. Kontak Kami</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 text-sm text-gray-600">
              <div>
                <p className="font-bold text-black mb-1 italic">Email Support</p>
                <p>arfcoderx@gmail.com</p>
              </div>
              <div>
                <p className="font-bold text-black mb-1 italic">WhatsApp</p>
                <p>083127378535</p>
              </div>
              <div className="md:col-span-2">
                <p className="font-bold text-black mb-1 italic">Alamat Kantor</p>
                <p>Jalan Kebun Baru Indah Blok Puhun Dusun 4 RT001/RW006, Kabupaten Cirebon</p>
              </div>
            </div>
          </section>
        </div>
      </main>
    </div>
  );
}
