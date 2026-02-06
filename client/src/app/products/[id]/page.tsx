'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { ShoppingCart, Zap, ShieldCheck, ArrowLeft, Star, Heart, Share2 } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { useRouter } from 'next/navigation';
import { useTranslation } from '@/lib/i18n';

export default function ProductDetail({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { t } = useTranslation();
  const [product, setProduct] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const addItem = useCartStore((state) => state.addItem);
  const router = useRouter();

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const res = await api.get(`/products/${id}`);
        setProduct(res.data);
      } catch (error) {
        toast.error('Product not found');
        router.push('/products');
      } finally {
        setLoading(false);
      }
    };
    fetchProduct();
  }, [id, router]);

  const handleAddToCart = () => {
    if (!product) return;
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - product.discount / 100),
      quantity: 1,
      image: product.images[0],
      paymentMethods: product.paymentMethods
    });
    toast.success(`${product.name} added!`);
  };

  const handleBuyNow = () => {
    handleAddToCart();
    router.push('/cart');
  };

  if (loading) return <div className="min-h-screen flex items-center justify-center font-bold">{t('common.loading')}</div>;
  if (!product) return null;

  const discountedPrice = product.price * (1 - product.discount / 100);

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-4 sm:px-8 py-12 pt-24">
        <button onClick={() => router.back()} className="flex items-center gap-2 text-sm font-bold text-gray-400 hover:text-black mb-10 transition-colors group">
          <ArrowLeft size={18} className="group-hover:-translate-x-1 transition-transform" /> {t('products.back')}
        </button>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">
          <div className="space-y-6">
            <div className="aspect-[4/3] bg-gray-50 rounded-[2.5rem] overflow-hidden border border-gray-100 shadow-inner">
              <img src={product.images[0] || 'https://placehold.co/800x600'} className="w-full h-full object-cover" alt="" />
            </div>
          </div>

          <div className="flex flex-col">
            <div className="flex items-center gap-3 mb-6">
              <span className="px-4 py-1.5 bg-secondary text-black text-[10px] font-black rounded-full uppercase tracking-widest border border-border">{product.type}</span>
              {product.discount > 0 && <span className="px-4 py-1.5 bg-black text-white text-[10px] font-black rounded-full uppercase tracking-widest animate-pulse">Save {product.discount}%</span>}
            </div>

            <h1 className="text-4xl md:text-5xl font-black tracking-tight mb-4 text-black leading-tight">{product.name}</h1>
            
            <div className="flex items-center gap-6 mb-10">
              <div className="flex flex-col">
                {product.discount > 0 && <span className="text-lg text-gray-400 line-through font-bold">Rp {product.price.toLocaleString()}</span>}
                <span className="text-4xl font-black text-black">Rp {discountedPrice.toLocaleString()}</span>
              </div>
              <div className="h-12 w-px bg-gray-100 hidden sm:block" />
              <div className="flex flex-col">
                <span className="text-xs font-black text-gray-400 uppercase tracking-widest">{t('products.stock')}</span>
                <span className="text-xl font-bold">{product.stock} Units</span>
              </div>
            </div>

            <div className="space-y-8 mb-12">
              <div>
                <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">{t('products.description')}</h3>
                <p className="text-gray-600 leading-relaxed text-lg">{product.description}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-auto">
              <button onClick={handleAddToCart} className="flex items-center justify-center gap-3 px-8 py-5 border-2 border-black rounded-2xl font-black hover:bg-gray-50 transition-all active:scale-95">
                <ShoppingCart size={20} /> {t('products.add_to_cart')}
              </button>
              <button onClick={handleBuyNow} className="flex items-center justify-center gap-3 px-8 py-5 bg-black text-white rounded-2xl font-black hover:bg-gray-800 transition-all active:scale-95 shadow-xl shadow-black/20">
                <Zap size={20} className="fill-white" /> {t('products.buy')}
              </button>
            </div>

            <div className="mt-12 p-6 bg-secondary/20 rounded-3xl border border-border flex items-center gap-4">
              <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm"><ShieldCheck className="text-green-600" /></div>
              <div>
                <p className="text-sm font-black text-black">Quality Guaranteed</p>
                <p className="text-xs text-muted-foreground">Original products with full support access.</p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}