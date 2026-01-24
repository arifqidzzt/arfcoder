'use client';

import { useEffect, useState, use } from 'react';
import ProductForm from '@/components/ProductForm';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import axios from 'axios';
import { useRouter } from 'next/navigation';

export default function EditProductPage({ params }: { params: Promise<{ id: string }> }) {
  // Unwrapping params for Next.js 15 compatibility
  const { id } = use(params);
  
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/products/${id}`);
        setProduct(res.data);
      } catch (error) {
        console.error('Error fetching product:', error);
      } finally {
        setLoading(false);
      }
    };

    if (id) fetchProduct();
  }, [id]);

  if (loading) return <div className="p-8 text-center">Memuat data produk...</div>;

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
           <Link href="/admin/products" className="p-2 hover:bg-gray-200 rounded-full transition-colors">
             <ArrowLeft size={20} />
           </Link>
           <div>
              <h1 className="text-2xl font-bold">Edit Produk</h1>
              <p className="text-gray-500">Perbarui informasi produk.</p>
           </div>
        </div>
        {product && <ProductForm initialData={product} isEdit />}
      </div>
    </div>
  );
}
