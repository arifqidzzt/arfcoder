'use client';

import Navbar from '@/components/Navbar';

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-white text-gray-800">
      <Navbar />
      <main className="max-w-4xl mx-auto px-8 py-16">
        <h1 className="text-4xl font-bold mb-8">Syarat dan Ketentuan</h1>
        
        <section className="space-y-6 text-sm leading-relaxed">
          <div>
            <h2 className="text-xl font-bold mb-4">1. Informasi Umum</h2>
            <p>
              Selamat datang di ArfCoder (arfzxdev.com). Dengan mengakses dan menggunakan situs web ini, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Jika Anda tidak setuju, mohon untuk tidak menggunakan layanan kami.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">2. Layanan Kami</h2>
            <p>
              ArfCoder menyediakan produk digital berupa template koding, aset desain, dan jasa pengembangan perangkat lunak (website dan aplikasi mobile).
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">3. Proses Pembelian</h2>
            <p>
              Semua transaksi dilakukan melalui sistem pembayaran resmi (Midtrans). Pelanggan wajib memberikan data yang akurat untuk keperluan pengiriman produk digital atau koordinasi jasa digital.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">4. Kebijakan Pengembalian Dana (Refund)</h2>
            <p>
              Karena sifat produk kami adalah aset digital yang dapat disalin secara instan, kami tidak menyediakan pengembalian dana setelah produk berhasil diunduh atau akses diberikan, kecuali terjadi kesalahan teknis permanen dari pihak kami yang membuat produk tidak dapat digunakan sama sekali.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">5. Keamanan Transaksi</h2>
            <p>
              Kami berkomitmen untuk menjaga keamanan data transaksi Anda. Semua data pembayaran diproses oleh Midtrans sesuai dengan standar industri keamanan data (PCI-DSS).
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">6. Kontak Kami</h2>
            <p>
              Jika Anda memiliki pertanyaan mengenai syarat ini, silakan hubungi kami di:<br />
              Email: arfzxcoder@gmail.com<br />
              WA: 08988289551<br />
              Alamat: Jl.Kebun Baru Indah Blok Puhun Dusun 4 Kabupaten Cirebon
            </p>
          </div>
        </section>
      </main>
    </div>
  );
}
