'use client';

import Navbar from '@/components/Navbar';

export default function RefundPolicyPage() {
  return (
    <div className="min-h-screen bg-white text-gray-800">
      <Navbar />
      <main className="max-w-4xl mx-auto px-8 py-16">
        <h1 className="text-4xl font-bold mb-8">Kebijakan Pengembalian Dana (Refund)</h1>
        
        <section className="space-y-6 text-sm leading-relaxed">
          <div>
            <h2 className="text-xl font-bold mb-4">1. Sifat Produk Digital</h2>
            <p>
              ArfCoder menyediakan produk digital berupa template koding, perangkat lunak, dan aset desain. Karena sifat produk digital yang dapat disalin dan digunakan secara instan setelah akses diberikan, maka semua pembelian bersifat final dan tidak dapat dibatalkan atau dikembalikan dananya.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">2. Pengecualian Refund</h2>
            <p>
              Refund atau pengembalian dana hanya akan dipertimbangkan dalam kondisi luar biasa berikut:
              <ul className="list-disc ml-6 mt-2">
                <li>Terjadi transaksi ganda untuk produk yang sama karena kesalahan sistem pembayaran.</li>
                <li>Produk digital yang dikirimkan rusak atau tidak dapat dibuka setelah tim teknis kami mencoba membantu memberikan solusi alternatif.</li>
                <li>Jasa digital (custom development) belum dikerjakan sama sekali dalam waktu 7 hari kerja sejak pembayaran dikonfirmasi tanpa pemberitahuan sebelumnya.</li>
              </ul>
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">3. Batas Waktu Pengajuan</h2>
            <p>
              Segala bentuk keluhan atau pengajuan refund harus disampaikan maksimal dalam waktu 24 jam setelah transaksi dilakukan melalui kontak resmi kami.
            </p>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">4. Proses Pengembalian</h2>
            <p>
              Jika pengajuan refund disetujui, dana akan dikembalikan melalui mekanisme yang tersedia di Midtrans atau melalui transfer bank manual dalam waktu 7-14 hari kerja.
            </p>
          </div>

          <div className="p-6 bg-gray-50 rounded-xl border border-gray-100 italic mt-12">
            "Dengan melakukan pembelian di arfzxdev.com, pelanggan dianggap telah membaca, memahami, dan menyetujui kebijakan pengembalian dana ini."
          </div>
        </section>
      </main>
    </div>
  );
}
