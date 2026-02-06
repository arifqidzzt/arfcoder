'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Navbar from '@/components/Navbar';
import { ArrowRight, Code, Rocket, CheckCircle, Mail, Phone, MapPin, Zap, Globe, Database, Smartphone } from 'lucide-react';
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
          {/* Background Circles */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 -right-20 md:-right-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" />
            <div className="absolute bottom-1/4 -left-20 md:-left-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" style={{ animationDelay: '1s' }} />
          </div>

          <div className="container-custom relative z-10 w-full px-4 overflow-hidden">
            <div className="max-w-4xl mx-auto text-center">
              <div data-aos="fade-down" className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full mb-6 md:mb-8 border border-border shadow-sm">
                <span className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-[10px] sm:text-xs md:text-sm font-medium text-muted-foreground uppercase tracking-widest">
                  Official Partner for Digital Transformation
                </span>
              </div>

              <h1 data-aos="fade-up" data-aos-delay="100" className="text-3xl sm:text-5xl md:text-7xl font-black tracking-tighter mb-6 md:mb-8 leading-[1.1] break-words text-black">
                {t('home.hero_title_part1')}<br />
                <span className="text-gradient block mt-2 pb-2">{t('home.hero_title_part2')}</span>
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
                <div data-aos="fade-up" data-aos-delay="400" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <Zap className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">{t('home.fast_delivery')}</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed italic">
                    Optimasi performa maksimal untuk load time di bawah 1 detik.
                  </p>
                </div>

                <div data-aos="fade-up" data-aos-delay="500" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <CheckCircle className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">{t('home.secure_payment')}</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed italic">
                    Struktur kode yang ramah mesin pencari untuk ranking terbaik.
                  </p>
                </div>

                <div data-aos="fade-up" data-aos-delay="600" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <Code className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">{t('home.best_support')}</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed italic">
                    Siap menangani pertumbuhan pengguna dari ratusan hingga jutaan.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* TECH STACK MARQUEE */}
        <section className="py-10 border-y border-border bg-secondary/30 overflow-hidden">
          <div className="w-full inline-flex flex-nowrap overflow-hidden [mask-image:_linear-gradient(to_right,transparent_0,_black_128px,_black_calc(100%-128px),transparent_100%)]">
            <ul className="flex items-center justify-center md:justify-start [&_li]:mx-8 animate-marquee text-muted-foreground font-black text-xl uppercase tracking-widest opacity-50">
              {languages.map((tech, i) => <li key={i} className="whitespace-nowrap">{tech}</li>)}
              {languages.map((tech, i) => <li key={`dup-${i}`} className="whitespace-nowrap">{tech}</li>)}
            </ul>
          </div>
        </section>

        {/* FLASH SALE SECTION */}
        {flashSales.length > 0 && (
          <section className="py-12 bg-black text-white">
            <div className="container-custom">
              <div className="flex items-center gap-4 mb-8 px-4">
                <div className="p-2 bg-yellow-500 rounded-lg animate-pulse">
                  <Zap className="text-black fill-black" size={24} />
                </div>
                <div>
                  <h2 className="text-3xl font-bold tracking-tight">FLASH SALE</h2>
                  <p className="text-gray-400">Penawaran terbatas, segera habiskan!</p>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 px-4">
                {flashSales.map((fs) => (
                  <Link href={`/products/${fs.productId}`} key={fs.id} className="bg-white/10 border border-white/20 p-6 rounded-2xl hover:bg-white/20 transition-all group">
                    <div className="flex justify-between items-start mb-4">
                      <span className="bg-red-600 px-3 py-1 rounded-full text-xs font-bold animate-bounce">
                        -{Math.round((1 - fs.discountPrice / fs.product.price) * 100)}%
                      </span>
                      <span className="text-xs font-mono text-gray-400">
                        Berakhir: {new Date(fs.endTime).toLocaleDateString()}
                      </span>
                    </div>
                    <h3 className="text-xl font-bold mb-2 group-hover:text-yellow-400 transition-colors">{fs.product.name}</h3>
                    <div className="flex items-end gap-3">
                      <span className="text-2xl font-bold text-yellow-400">Rp {fs.discountPrice.toLocaleString()}</span>
                      <span className="text-sm text-gray-500 line-through mb-1">Rp {fs.product.price.toLocaleString()}</span>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* PREVIEW PRODUCTS SECTION */}
        <section className="py-24 bg-secondary/20">
          <div className="container-custom px-4">
            <div data-aos="fade-right" className="flex flex-col md:flex-row justify-between items-end mb-12 gap-4">
              <div>
                <span className="text-accent font-black tracking-widest uppercase text-xs mb-3 block">{t('navbar.products')}</span>
                <h2 className="text-3xl md:text-4xl font-black tracking-tight">{t('home.latest_products')}</h2>
              </div>
              <Link href="/products" className="inline-flex items-center justify-center px-6 py-3 rounded-lg border border-border bg-white hover:bg-gray-50 transition-colors font-medium">
                {t('home.view_all')}
              </Link>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredProducts.length === 0 ? (
                <div className="col-span-3 text-center py-10 text-gray-400 italic">Belum ada produk di database.</div>
              ) : (
                featuredProducts.map((product: any, idx) => (
                  <Link href={`/products/${product.id}`} key={product.id} data-aos="fade-up" data-aos-delay={idx * 100} className="group cursor-pointer bg-white rounded-[2rem] p-5 border border-border hover:border-accent/30 transition-all hover:shadow-2xl">
                    <div className="bg-gray-100 rounded-2xl aspect-[16/10] mb-6 overflow-hidden relative shadow-inner">
                      <img src={product.images[0] || 'https://placehold.co/600x400'} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" alt="" />
                    </div>
                    <div className="px-2">
                      <h3 className="text-xl font-bold mb-1 group-hover:text-accent transition-colors">{product.name}</h3>
                      <p className="text-muted-foreground text-sm line-clamp-1 mb-4 leading-relaxed italic">{product.description}</p>
                      <div className="flex justify-between items-center">
                        <span className="font-black text-2xl text-black">Rp {product.price.toLocaleString('id-ID')}</span>
                        <div className="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center group-hover:translate-x-1 transition-transform shadow-lg shadow-black/20"><ArrowRight size={18} /></div>
                      </div>
                    </div>
                  </Link>
                ))
              )}
            </div>
          </div>
        </section>

        {/* SERVICES SECTION */}
        <section className="py-24 bg-white">
          <div className="container-custom px-4">
            <div data-aos="fade-up" className="text-center max-w-3xl mx-auto mb-20">
              <span className="text-accent font-black tracking-widest uppercase text-xs mb-3 block">{t('navbar.services')}</span>
              <h2 className="text-3xl md:text-5xl font-black mb-6 tracking-tighter">{t('home.help_title')}</h2>
              <p className="text-muted-foreground text-lg leading-relaxed">
                {t('home.help_desc')}
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[
                { icon: <Globe />, title: "Web Development", desc: "Website performa tinggi dengan teknologi terbaru." },
                { icon: <Smartphone />, title: "Mobile Apps", desc: "Aplikasi Android & iOS yang responsif." },
                { icon: <Database />, title: "Backend System", desc: "Arsitektur server yang aman dan scalable." }
              ].map((s, i) => (
                <div key={i} data-aos="fade-up" data-aos-delay={i * 100} className="p-10 rounded-[2.5rem] border border-border bg-secondary/10 hover:bg-white hover:shadow-2xl transition-all group">
                  <div className="w-14 h-14 mb-8 bg-black text-white flex items-center justify-center rounded-2xl group-hover:rotate-6 transition-transform shadow-xl shadow-black/10">{s.icon}</div>
                  <h3 className="text-2xl font-bold mb-4 tracking-tight">{s.title}</h3>
                  <p className="text-muted-foreground leading-relaxed">{s.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="py-32 relative overflow-hidden bg-black text-white mx-4 my-12 rounded-[3rem]">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-accent/20 via-transparent to-transparent opacity-50" />
          <div className="container-custom relative z-10 text-center px-4">
            <h2 data-aos="zoom-in" className="text-4xl md:text-6xl font-black mb-8 tracking-tighter leading-none">{t('home.start_transform')}</h2>
            <div data-aos="fade-up" data-aos-delay="200" className="flex flex-col sm:flex-row gap-6 justify-center mt-12">
              <Link href="/register" className="px-10 py-5 bg-white text-black rounded-2xl font-black hover:bg-gray-100 transition-all hover:scale-105 shadow-xl">{t('home.register_now')}</Link>
              <Link href="/contact" className="px-10 py-5 bg-transparent border-2 border-white/20 text-white rounded-2xl font-black hover:bg-white/10 transition-all">{t('home.contact_sales')}</Link>
            </div>
          </div>
        </section>
      </main>

      {/* FOOTER */}
      <footer className="bg-white pt-24 pb-12 border-t border-border px-6 md:px-12">
        <div className="container-custom">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-16 mb-20">
            <div className="col-span-1">
              <Link href="/" className="text-3xl font-black tracking-tighter block mb-8">ARFCODER</Link>
              <p className="text-muted-foreground text-sm leading-relaxed max-w-xs italic">
                {t('footer.desc')}
              </p>
            </div>
            <div>
              <h4 className="font-black text-xs uppercase tracking-widest text-black mb-8">{t('footer.company')}</h4>
              <ul className="space-y-4 text-sm font-bold text-muted-foreground">
                <li><Link href="/services" className="hover:text-black transition-colors">{t('navbar.services')}</Link></li>
                <li><Link href="/products" className="hover:text-black transition-colors">{t('navbar.products')}</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-black text-xs uppercase tracking-widest text-black mb-8">{t('footer.support')}</h4>
              <ul className="space-y-4 text-sm font-bold text-muted-foreground">
                <li><Link href="/terms" className="hover:text-black transition-colors">{t('policy.terms')}</Link></li>
                <li><Link href="/privacy" className="hover:text-black transition-colors">{t('policy.privacy')}</Link></li>
                <li><Link href="/refund-policy" className="hover:text-black transition-colors">{t('policy.refund')}</Link></li>
                <li><Link href="/faq" className="hover:text-black transition-colors">{t('policy.faq')}</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-black text-xs uppercase tracking-widest text-black mb-8">{t('footer.contact')}</h4>
              <ul className="space-y-4 text-sm font-bold text-muted-foreground">
                <li className="flex items-start gap-3"><MapPin className="text-accent w-5 h-5 shrink-0"/> <span>Jl.Kebun Baru Indah Blok Puhun Dusun 4 Kabupaten Cirebon</span></li>
                <li className="flex items-center gap-3"><Phone className="text-accent w-5 h-5 shrink-0"/> <span>08988289551</span></li>
                <li className="flex items-center gap-3"><Mail className="text-accent w-5 h-5 shrink-0"/> <span>arfzxcoder@gmail.com</span></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-border pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-xs font-bold text-muted-foreground italic">
            <p>© 2026 ArfCoder. {t('footer.rights')}</p>
            <div className="flex gap-6">
              <span>DESIGNED BY ARF</span>
              <span>DEVELOPED WITH NEXTJS 15</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
