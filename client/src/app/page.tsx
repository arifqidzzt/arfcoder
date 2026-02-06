'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Navbar from '@/components/Navbar';
import { ArrowRight, Code, CheckCircle, Zap, Globe, Database, Smartphone } from 'lucide-react';
import api from '@/lib/api';
import { useTranslation } from '@/lib/i18n';

export default function Home() {
  const { t } = useTranslation();
  const [featuredProducts, setFeaturedProducts] = useState([]);
  const [flashSales, setFlashSales] = useState<any[]>([]);
  
  const languages = [
    "JavaScript", "TypeScript", "Python", "Go", "Java", "PHP", "Rust", "C++", "Swift", "Kotlin", "Ruby", "Dart"
  ];

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [pRes, fsRes] = await Promise.all([
          api.get('/products'),
          api.get('/flash-sales/active')
        ]);
        setFeaturedProducts(pRes.data.slice(0, 3)); 
        setFlashSales(fsRes.data);
      } catch (error) {
        console.error("Failed to fetch data");
      }
    };
    fetchData();
  }, []);

  return (
    <div className="flex flex-col min-h-screen bg-background overflow-x-hidden w-full">
      <Navbar />

      <main className="flex-grow w-full">
        {/* HERO SECTION */}
        <section className="relative min-h-[90vh] flex items-center pt-20 pb-16 md:pt-24 md:pb-20 bg-grid-pattern">
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 -right-20 md:-right-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" />
            <div className="absolute bottom-1/4 -left-20 md:-left-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" style={{ animationDelay: '1s' }} />
          </div>

          <div className="container-custom relative z-10 w-full px-4 overflow-hidden">
            <div className="max-w-4xl mx-auto text-center">
              <div data-aos="fade-down" className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full mb-6 md:mb-8 border border-border shadow-sm">
                <span className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-[10px] sm:text-xs md:text-sm font-medium text-muted-foreground">
                  Official Partner for Digital Transformation
                </span>
              </div>

              <h1 data-aos="fade-up" data-aos-delay="100" className="text-3xl sm:text-5xl md:text-7xl font-bold tracking-tight mb-6 md:mb-8 leading-[1.1] break-words">
                {t('home.hero_title')}
              </h1>

              <p data-aos="fade-up" data-aos-delay="200" className="text-sm sm:text-base md:text-xl text-muted-foreground max-w-2xl mx-auto mb-8 md:mb-10 leading-relaxed">
                {t('home.hero_desc')}
              </p>

              <div data-aos="fade-up" data-aos-delay="300" className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16 md:mb-20">
                <Link href="/products" className="btn-hero-primary group w-full sm:w-auto">
                  <span>{t('home.shop_now')}</span>
                  <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
                </Link>
                <Link href="/services" className="btn-hero-secondary w-full sm:w-auto">
                  {t('home.our_services')}
                </Link>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 md:gap-6 text-left">
                <div data-aos="fade-up" data-aos-delay="400" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4"><Zap className="w-5 h-5" /></div>
                  <h3 className="text-lg font-bold mb-2">{t('home.fast_delivery')}</h3>
                  <p className="text-sm text-muted-foreground">Optimized for maximum speed.</p>
                </div>
                <div data-aos="fade-up" data-aos-delay="500" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4"><CheckCircle className="w-5 h-5" /></div>
                  <h3 className="text-lg font-bold mb-2">{t('home.secure_payment')}</h3>
                  <p className="text-sm text-muted-foreground">Encryption & Data security.</p>
                </div>
                <div data-aos="fade-up" data-aos-delay="600" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4"><Code className="w-5 h-5" /></div>
                  <h3 className="text-lg font-bold mb-2">{t('home.best_support')}</h3>
                  <p className="text-sm text-muted-foreground">24/7 technical assistance.</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* FLASH SALE */}
        {flashSales.length > 0 && (
          <section className="py-12 bg-black text-white">
            <div className="container-custom px-4">
              <h2 className="text-3xl font-bold mb-8 flex items-center gap-2"><Zap className="text-yellow-500 fill-yellow-500" /> FLASH SALE</h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {flashSales.map((fs) => (
                  <Link href={`/products/${fs.productId}`} key={fs.id} className="bg-white/10 border border-white/20 p-6 rounded-2xl">
                    <h3 className="text-xl font-bold mb-2">{fs.product.name}</h3>
                    <p className="text-yellow-400 font-bold text-2xl">Rp {fs.discountPrice.toLocaleString()}</p>
                  </Link>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* PREVIEW PRODUCTS */}
        <section className="py-24 bg-secondary/20">
          <div className="container-custom px-4">
            <div className="flex justify-between items-end mb-12">
              <h2 className="text-3xl font-bold">{t('home.featured_products')}</h2>
              <Link href="/products" className="text-sm font-bold border-b-2 border-black pb-1">View All</Link>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredProducts.map((p: any) => (
                <Link href={`/products/${p.id}`} key={p.id} className="bg-white rounded-2xl p-4 border shadow-sm">
                  <div className="bg-gray-100 rounded-xl aspect-video mb-4 overflow-hidden">
                    <img src={p.images[0] || 'https://placehold.co/600x400'} className="w-full h-full object-cover" />
                  </div>
                  <h3 className="font-bold mb-1">{p.name}</h3>
                  <p className="text-sm font-bold text-accent">Rp {p.price.toLocaleString()}</p>
                </Link>
              ))}
            </div>
          </div>
        </section>
      </main>

      <footer className="bg-white pt-20 pb-12 border-t px-4">
        <div className="container-custom">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
            <div className="col-span-1">
              <span className="text-2xl font-black tracking-tighter block mb-6">ARFCODER</span>
              <p className="text-muted-foreground text-sm leading-relaxed">{t('footer.desc')}</p>
            </div>
            <div>
              <h4 className="font-bold mb-6">{t('footer.quick_links')}</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li><Link href="/products">{t('navbar.products')}</Link></li>
                <li><Link href="/services">{t('navbar.services')}</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-6">{t('footer.support')}</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li><Link href="/faq">Help Center</Link></li>
                <li><Link href="/terms">Terms</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-6">{t('footer.contact')}</h4>
              <p className="text-sm text-muted-foreground leading-relaxed">arfzxcoder@gmail.com<br />08988289551</p>
            </div>
          </div>
          <div className="border-t pt-8 text-center text-xs text-muted-foreground">© 2026 ArfCoder. {t('footer.rights')}</div>
        </div>
      </footer>
    </div>
  );
}