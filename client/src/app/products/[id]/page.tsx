'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { ShoppingCart, Heart, Share2, ArrowLeft, Minus, Plus, Truck, ShieldCheck } from 'lucide-react';
import axios from 'axios';
import toast from 'react-hot-toast';
import Link from 'next/link';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  discount: number;
  stock: number;
  images: string[];
  category: { name: string } | null;
  type: string;
}

export default function ProductDetailPage({ params }: { params: Promise<{ id: string }> }) {
  // Unwrapping params for Next.js 15
  const { id } = use(params);

  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const addItem = useCartStore((state) => state.addItem);

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/products/${id}`);
        setProduct(res.data);
      } catch (error) {
        toast.error('Produk tidak ditemukan');
      } finally {
        setLoading(false);
      }
    };

    if (id) fetchProduct();
  }, [id]);

  const handleAddToCart = () => {
    if (!product) return;
    
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - product.discount / 100),
      quantity: quantity,
      image: product.images[0] || 'https://placehold.co/600x400/000000/FFFFFF?text=No+Image',
    });
    toast.success('Berhasil ditambahkan ke keranjang');
  };

  const incrementQty = () => {
    if (product && quantity < product.stock) setQuantity(q => q + 1);
  };

  const decrementQty = () => {
    if (quantity > 1) setQuantity(q => q - 1);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-white">
        <Navbar />
        <div className="max-w-7xl mx-auto px-8 py-24 text-center">
          <div className="animate-pulse flex flex-col items-center">
            <div className="h-64 w-full md:w-1/2 bg-gray-200 rounded-xl mb-8"></div>
            <div className="h-8 w-1/3 bg-gray-200 rounded mb-4"></div>
            <div className="h-4 w-1/4 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className="min-h-screen bg-white">
        <Navbar />
        <div className="max-w-7xl mx-auto px-8 py-24 text-center">
          <h1 className="text-2xl font-bold mb-4">Produk Tidak Ditemukan</h1>
          <Link href="/products" className="text-blue-600 hover:underline">Kembali ke Katalog</Link>
        </div>
      </div>
    );
  }

  const finalPrice = product.price * (1 - product.discount / 100);

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Breadcrumb */}
        <div className="flex items-center text-sm text-gray-500 mb-8">
          <Link href="/products" className="hover:text-black flex items-center gap-1">
            <ArrowLeft size={16} /> Kembali
          </Link>
          <span className="mx-2">/</span>
          <span className="capitalize">{product.type.toLowerCase()}</span>
          <span className="mx-2">/</span>
          <span className="text-black font-medium line-clamp-1">{product.name}</span>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-24">
          {/* Left: Images */}
          <div className="space-y-4">
            <div className="aspect-square bg-gray-100 rounded-2xl overflow-hidden border border-gray-100 relative group">
              <img 
                src={product.images[0] || 'https://placehold.co/600x400/000000/FFFFFF?text=No+Image'} 
                alt={product.name}
                className="w-full h-full object-cover"
              />
              {product.discount > 0 && (
                <span className="absolute top-4 left-4 bg-red-600 text-white px-3 py-1 rounded-full text-xs font-bold tracking-wider">
                  SALE -{product.discount}%
                </span>
              )}
            </div>
          </div>

          {/* Right: Info */}
          <div className="flex flex-col">
            <div className="mb-2">
               <span className="text-sm font-bold text-accent tracking-wider uppercase">{product.category?.name || 'Digital Product'}</span>
            </div>
            <h1 className="text-3xl md:text-4xl font-bold tracking-tight mb-4">{product.name}</h1>
            
            <div className="flex items-end gap-4 mb-8">
              <span className="text-3xl font-bold">
                Rp {finalPrice.toLocaleString('id-ID')}
              </span>
              {product.discount > 0 && (
                <span className="text-xl text-gray-400 line-through mb-1">
                  Rp {product.price.toLocaleString('id-ID')}
                </span>
              )}
            </div>

            <div className="prose prose-sm text-gray-600 mb-8 leading-relaxed">
              <p>{product.description}</p>
            </div>

            {/* Actions */}
            <div className="space-y-6 pt-8 border-t border-gray-100">
              <div className="flex items-center gap-6">
                <span className="font-medium text-sm">Jumlah</span>
                <div className="flex items-center border border-gray-300 rounded-lg">
                  <button 
                    onClick={decrementQty}
                    className="p-3 hover:bg-gray-50 transition-colors disabled:opacity-50"
                    disabled={quantity <= 1}
                  >
                    <Minus size={16} />
                  </button>
                  <span className="w-12 text-center font-medium">{quantity}</span>
                  <button 
                    onClick={incrementQty}
                    className="p-3 hover:bg-gray-50 transition-colors disabled:opacity-50"
                    disabled={quantity >= product.stock}
                  >
                    <Plus size={16} />
                  </button>
                </div>
                <span className="text-sm text-gray-500">
                  Stok: {product.stock} unit
                </span>
              </div>

              <div className="flex gap-4">
                <button 
                  onClick={handleAddToCart}
                  className="flex-1 bg-black text-white py-4 rounded-xl font-bold flex items-center justify-center gap-2 hover:bg-gray-800 transition-all hover:shadow-lg active:scale-95"
                >
                  <ShoppingCart size={20} />
                  Tambah ke Keranjang
                </button>
                <button className="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
                  <Heart size={20} />
                </button>
                <button className="p-4 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
                  <Share2 size={20} />
                </button>
              </div>
            </div>

            {/* Features */}
            <div className="grid grid-cols-2 gap-4 mt-12">
              <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-xl">
                <Truck className="w-6 h-6 text-gray-600 mt-1" />
                <div>
                  <h4 className="font-bold text-sm">Pengiriman Instan</h4>
                  <p className="text-xs text-gray-500 mt-1">Produk digital dikirim via email.</p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-xl">
                <ShieldCheck className="w-6 h-6 text-gray-600 mt-1" />
                <div>
                  <h4 className="font-bold text-sm">Jaminan Aman</h4>
                  <p className="text-xs text-gray-500 mt-1">Transaksi terenkripsi 100%.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
