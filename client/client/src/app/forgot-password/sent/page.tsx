'use client';

import Navbar from '@/components/Navbar';
import { MailCheck } from 'lucide-react';
import Link from 'next/link';

export default function ForgotPasswordSentPage() {
  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-md mx-auto px-8 py-32 text-center">
        <div className="w-20 h-20 bg-green-50 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
          <MailCheck size={40} />
        </div>
        <h1 className="text-3xl font-bold mb-4">Link Terkirim!</h1>
        <p className="text-gray-500 mb-8 leading-relaxed">
          Kami telah mengirimkan tautan untuk mengatur ulang kata sandi ke email Anda. Silakan cek kotak masuk atau folder spam.
        </p>
        <Link href="/login" className="block w-full py-4 bg-gray-100 text-gray-700 rounded-xl font-bold hover:bg-gray-200 transition-colors">
          Kembali ke Login
        </Link>
      </main>
    </div>
  );
}
