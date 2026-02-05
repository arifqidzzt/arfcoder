'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { ShoppingCart, Heart, Share2, ArrowLeft, Minus, Plus, Truck, ShieldCheck, Star, MessageSquare } from 'lucide-react';
import api from '@/lib/api';
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

interface Review {
  id: string;
  rating: number;
  comment: string;
  user: { name: string; avatar: string };
  createdAt: string;
}

export default function ProductDetailPage({ params }: { params: Promise<{ id: string }> }) {
  // Unwrapping params for Next.js 15
  const { id } = use(params);
  const { user } = useAuthStore();

  const [product, setProduct] = useState<Product | null>(null);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const addItem = useCartStore((state) => state.addItem);

  // Review Form
  const [rating, setRating] = useState(5);
  const [comment, setComment] = useState('');
  const [submittingReview, setSubmittingReview] = useState(false);

  const fetchProductAndReviews = async () => {
    try {
      const [pRes, rRes] = await Promise.all([
        api.get(`/products/${id}`),
        api.get(`/reviews/${id}`)
      ]);
      setProduct(pRes.data);
      setReviews(rRes.data);
    } catch (error) {
      toast.error('Produk tidak ditemukan');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) fetchProductAndReviews();
  }, [id]);

  const handleAddToCart = () => {
    if (!product) return;
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - product.discount / 100),
      quantity: quantity,
      image: product.images[0] || 'https://placehold.co/600x400',
    });
    toast.success('Berhasil ditambahkan ke keranjang');
  };

  const submitReview = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return toast.error('Login dulu bos!');
    
    setSubmittingReview(true);
    try {
      await api.post('/reviews', { productId: id, rating, comment });
      toast.success('Ulasan terkirim!');
      setComment('');
      fetchProductAndReviews(); // Refresh
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Gagal mengirim ulasan');
    } finally {
      setSubmittingReview(false);
    }
  };

  if (loading) return <div className="min-h-screen bg-white pt-24 text-center">Loading...</div>;
  if (!product) return <div className="min-h-screen bg-white pt-24 text-center">Produk 404</div>;

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
                src={product.images[0] || 'https://placehold.co/600x400'} 
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
                    onClick={() => setQuantity(q => Math.max(1, q - 1))}
                    className="p-3 hover:bg-gray-50 transition-colors disabled:opacity-50"
                    disabled={quantity <= 1}
                  >
                    <Minus size={16} />
                  </button>
                  <span className="w-12 text-center font-medium">{quantity}</span>
                  <button 
                    onClick={() => setQuantity(q => Math.min(product.stock, q + 1))}
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

        {/* REVIEWS SECTION */}
        <section className="mt-24 border-t border-gray-100 pt-16">
          <h2 className="text-2xl font-bold mb-8 flex items-center gap-2">
            <MessageSquare size={24} /> Ulasan Pembeli ({reviews.length})
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            {/* Review Form */}
            <div className="bg-gray-50 p-8 rounded-3xl h-fit">
              <h3 className="font-bold text-lg mb-4">Tulis Ulasan</h3>
              {user ? (
                <form onSubmit={submitReview} className="space-y-4">
                  <div>
                    <label className="text-xs font-bold uppercase text-gray-500">Rating</label>
                    <div className="flex gap-2 mt-1">
                      {[1, 2, 3, 4, 5].map((s) => (
                        <button key={s} type="button" onClick={() => setRating(s)} className="focus:outline-none">
                          <Star size={24} className={s <= rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'} />
                        </button>
                      ))}
                    </div>
                  </div>
                  <div>
                    <label className="text-xs font-bold uppercase text-gray-500">Komentar</label>
                    <textarea 
                      className="w-full p-4 rounded-xl border border-gray-200 mt-1 focus:outline-none focus:border-black"
                      rows={4}
                      placeholder="Bagaimana pengalaman Anda menggunakan produk ini?"
                      value={comment}
                      onChange={e => setComment(e.target.value)}
                      required
                    />
                  </div>
                  <button 
                    disabled={submittingReview}
                    className="w-full bg-black text-white py-3 rounded-xl font-bold hover:bg-gray-800 disabled:bg-gray-400"
                  >
                    {submittingReview ? 'Mengirim...' : 'Kirim Ulasan'}
                  </button>
                  <p className="text-xs text-gray-500 mt-2">*Hanya pembeli yang sudah menyelesaikan pesanan yang bisa memberi ulasan.</p>
                </form>
              ) : (
                <div className="text-center py-8">
                  <p className="mb-4">Silakan login untuk menulis ulasan.</p>
                  <Link href="/login" className="px-6 py-2 bg-black text-white rounded-full font-bold text-sm">Login</Link>
                </div>
              )}
            </div>

            {/* Review List */}
            <div className="space-y-6">
              {reviews.length === 0 ? (
                <p className="text-gray-400 italic">Belum ada ulasan untuk produk ini.</p>
              ) : (
                reviews.map((review) => (
                  <div key={review.id} className="border-b border-gray-100 pb-6 last:border-0">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center font-bold text-gray-500 uppercase">
                          {review.user.name?.[0] || 'U'}
                        </div>
                        <div>
                          <h4 className="font-bold text-sm">{review.user.name}</h4>
                          <p className="text-xs text-gray-400">{new Date(review.createdAt).toLocaleDateString()}</p>
                        </div>
                      </div>
                      <div className="flex text-yellow-400">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <Star key={i} size={14} className={i < review.rating ? 'fill-current' : 'text-gray-200'} />
                        ))}
                      </div>
                    </div>
                    <p className="text-gray-600 text-sm leading-relaxed bg-gray-50 p-4 rounded-xl rounded-tl-none">
                      {review.comment}
                    </p>
                  </div>
                ))
              )}
            </div>
          </div>
        </section>

      </main>
    </div>
  );
}
