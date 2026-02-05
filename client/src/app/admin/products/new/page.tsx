'use client';

import ProductForm from '@/components/ProductForm';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';

export default function NewProductPage() {
  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
           <Link href="/admin/products" className="p-2 hover:bg-gray-200 rounded-full transition-colors">
             <ArrowLeft size={20} />
           </Link>
           <div>
              <h1 className="text-2xl font-bold">Tambah Produk Baru</h1>
              <p className="text-gray-500">Isi detail produk di bawah ini.</p>
           </div>
        </div>
        <ProductForm />
      </div>
    </div>
  );
}
