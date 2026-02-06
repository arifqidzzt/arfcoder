'use client';

import Navbar from '@/components/Navbar';

export default function RefundPolicyPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">
      <Navbar />
      <main className="max-w-4xl mx-auto px-6 py-24 md:py-32">
        <div className="mb-16 border-b pb-8">
          <h1 className="text-3xl md:text-4xl font-black tracking-tight mb-4">Kebijakan Refund</h1>
          <p className="text-gray-500 text-sm italic">Terakhir diperbarui: 6 Februari 2026</p>
        </div>
        
        <div className="prose prose-gray max-w-none space-y-12">
          <section>
            <h2 className="text-xl font-bold mb-4 text-black">1. Sifat Produk Digital</h2>
            <p className="text-gray-600 leading-relaxed italic">
              ArfCoder menyediakan produk digital berupa template koding, perangkat lunak, dan aset desain. Karena sifat produk digital yang dapat disalin dan digunakan secara instan setelah akses diberikan, maka semua pembelian bersifat final dan tidak dapat dikembalikan dananya.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">2. Pengecualian Refund</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Refund hanya akan dipertimbangkan dalam kondisi luar biasa: transaksi ganda akibat kesalahan sistem, produk terbukti rusak secara teknis setelah bantuan tim kami, atau jasa custom belum dikerjakan sama sekali melewati batas waktu tanpa pemberitahuan.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">3. Batas Waktu Pengajuan</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Segala bentuk keluhan atau pengajuan refund harus disampaikan maksimal dalam waktu 24 jam setelah transaksi dilakukan melalui kontak resmi kami untuk diverifikasi oleh tim teknis.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold mb-4 text-black">4. Proses Pengembalian</h2>
            <p className="text-gray-600 leading-relaxed italic">
              Jika pengajuan refund disetujui, dana akan dikembalikan melalui mekanisme asli pembayaran atau transfer bank manual dalam waktu 7-14 hari kerja.
            </p>
          </section>

          <div className="mt-12 p-8 bg-gray-50 rounded-2xl border border-gray-100 text-sm italic text-gray-500 text-center">
            "Dengan melakukan pembelian di arfzxdev.com, pelanggan dianggap telah membaca dan menyetujui seluruh syarat dalam kebijakan pengembalian dana ini."
          </div>
        </div>
      </main>
    </div>
  );
}
