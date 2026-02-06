'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Navbar from '@/components/Navbar';
import { ArrowRight, Code, CheckCircle, Zap, Globe, Database, Smartphone, ShoppingCart } from 'lucide-react';
import api from '@/lib/api';
import { useTranslation } from '@/lib/i18n';
import { useCartStore } from '@/store/useCartStore';
import toast from 'react-hot-toast';

export default function Home() {
  const { t } = useTranslation();
  const [featuredProducts, setFeaturedProducts] = useState([]);
  const [flashSales, setFlashSales] = useState<any[]>([]);
  const { user } = useAuthStore();
  const addItem = useCartStore((state) => state.addItem);
  
  const languages = [
    "JavaScript", "TypeScript", "Python", "Go", "Java", "PHP", "Rust", "Kotlin", "Ruby", "Dart", "Swift", "C++"
  ];

  const techLogos: { [key: string]: string } = {
    "JavaScript": "javascript",
    "TypeScript": "typescript",
    "Python": "python",
    "Go": "go",
    "Java": "java",
    "PHP": "php",
    "Rust": "rust",
    "Kotlin": "kotlin",
    "Ruby": "ruby",
    "Dart": "dart",
    "Swift": "swift",
    "C++": "cplusplus"
  };

  const handleAddToCart = (e: React.MouseEvent, product: any) => {
    e.preventDefault();
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - (product.discount || 0) / 100),
      quantity: 1,
      image: product.images[0],
      paymentMethods: product.paymentMethods
    });
    toast.success(`${product.name} added to cart!`);
  };

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
    <div className="flex flex-col min-h-screen bg-background overflow-x-hidden w-full text-black">
      <Navbar />

      <main className="flex-grow w-full">
        {/* HERO SECTION */}
        <section className="relative min-h-[85vh] flex items-center pt-20 pb-16 bg-grid-pattern">
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 -right-20 w-64 h-64 bg-accent/5 rounded-full blur-3xl animate-pulse" />
          </div>

          <div className="container-custom relative z-10 w-full px-4">
            <div className="max-w-4xl mx-auto text-center">
              <div data-aos="fade-down" className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full mb-8 border border-border shadow-sm">
                <span className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-[10px] sm:text-xs font-bold text-muted-foreground uppercase tracking-widest">
                  Official Partner for Digital Transformation
                </span>
              </div>

              <h1 data-aos="fade-up" data-aos-delay="100" className="text-4xl sm:text-6xl md:text-7xl font-black tracking-tighter mb-8 leading-[1.1]">
                {t('home.hero_title_part1')}<br />
                <span className="text-gradient block mt-2 pb-2">{t('home.hero_title_part2')}</span>
              </h1>

              <p data-aos="fade-up" data-aos-delay="200" className="text-sm sm:text-base md:text-lg text-muted-foreground max-w-2xl mx-auto mb-10 leading-relaxed italic">
                {t('home.hero_desc')}
              </p>

              <div data-aos="fade-up" data-aos-delay="300" className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-20">
                <Link href="/products" className="btn-hero-primary group w-full sm:w-auto">
                  <span>{t('home.shop_now')}</span>
                  <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
                </Link>
                <Link href="/services" className="btn-hero-secondary w-full sm:w-auto">
                  {t('home.our_services')}
                </Link>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 text-left">
                <div data-aos="fade-up" data-aos-delay="400" className="flex flex-col p-8 rounded-3xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-12 h-12 rounded-2xl bg-black text-white flex items-center justify-center mb-6"><Zap className="w-6 h-6" /></div>
                  <h3 className="text-xl font-bold mb-3">{t('home.fast_delivery')}</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed italic">Optimized performance for sub-second load times.</p>
                </div>
                <div data-aos="fade-up" data-aos-delay="500" className="flex flex-col p-8 rounded-3xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-12 h-12 rounded-2xl bg-black text-white flex items-center justify-center mb-6"><CheckCircle className="w-6 h-6" /></div>
                  <h3 className="text-xl font-bold mb-3">{t('home.secure_payment')}</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed italic">Bank-level encryption for every single transaction.</p>
                </div>
                <div data-aos="fade-up" data-aos-delay="600" className="flex flex-col p-8 rounded-3xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-12 h-12 rounded-2xl bg-black text-white flex items-center justify-center mb-6"><Code className="w-6 h-6" /></div>
                  <h3 className="text-xl font-bold mb-3">{t('home.best_support')}</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed italic">Direct access to technical experts 24/7.</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* TECH STACK MARQUEE WITH LOGOS (LARGER) */}
        <section className="py-20 border-y border-border bg-secondary/30 overflow-hidden">
          <div className="w-full inline-flex flex-nowrap overflow-hidden [mask-image:_linear-gradient(to_right,transparent_0,_black_128px,_black_calc(100%-128px),transparent_100%)]">
            <ul className="flex items-center justify-center md:justify-start [&_li]:mx-20 animate-marquee text-muted-foreground font-black text-xl uppercase tracking-[0.3em] opacity-80">
              {languages.map((tech, i) => (
                <li key={i} className="whitespace-nowrap flex flex-col items-center gap-6">
                  <img 
                    src={`https://cdn.simpleicons.org/${techLogos[tech] || tech.toLowerCase()}/gray`} 
                    alt="" 
                    className="w-20 h-20 object-contain opacity-60 hover:opacity-100 transition-opacity" 
                  />
                  <span className="text-lg">{tech}</span>
                </li>
              ))}
              {languages.map((tech, i) => (
                <li key={`dup-${i}`} className="whitespace-nowrap flex flex-col items-center gap-6">
                  <img 
                    src={`https://cdn.simpleicons.org/${techLogos[tech] || tech.toLowerCase()}/gray`} 
                    alt="" 
                    className="w-20 h-20 object-contain opacity-60 hover:opacity-100 transition-opacity" 
                  />
                  <span className="text-lg">{tech}</span>
                </li>
              ))}
            </ul>
          </div>
        </section>

        {/* LATEST PRODUCTS */}
        <section className="py-24 bg-white">
          <div className="container-custom px-4">
            <div className="flex flex-col md:flex-row justify-between items-end mb-12 gap-4">
              <div data-aos="fade-right">
                <span className="text-accent font-black tracking-widest uppercase text-xs mb-3 block">{t('navbar.products')}</span>
                <h2 className="text-3xl md:text-5xl font-black tracking-tight">{t('home.latest_products')}</h2>
              </div>
              <Link href="/products" className="btn-hero-secondary text-sm px-8 py-3" data-aos="fade-left">{t('home.view_all')}</Link>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredProducts.map((product: any, idx) => (
                <Link href={`/products/${product.id}`} key={product.id} data-aos="fade-up" data-aos-delay={idx * 100} className="group bg-white rounded-[2rem] p-5 border border-border hover:border-accent/30 transition-all hover:shadow-2xl flex flex-col">
                  <div className="bg-gray-100 rounded-2xl aspect-[16/10] mb-6 overflow-hidden relative shadow-inner">
                    <img src={product.images[0] || 'https://placehold.co/600x400'} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" alt="" />
                    <div className="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                      <button 
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          handleAddToCart(e, product);
                        }}
                        className="w-12 h-12 rounded-full bg-white text-black flex items-center justify-center hover:bg-accent hover:text-white transition-all transform scale-90 group-hover:scale-100 duration-300"
                      >
                        <ShoppingCart size={20} />
                      </button>
                    </div>
                  </div>
                  <div className="flex-grow">
                    <h3 className="text-xl font-bold mb-2 group-hover:text-accent transition-colors">{product.name}</h3>
                    <p className="text-muted-foreground text-sm line-clamp-2 mb-6 leading-relaxed italic">{product.description}</p>
                    <div className="flex justify-between items-center mt-auto">
                      <span className="font-black text-2xl">Rp {product.price.toLocaleString('id-ID')}</span>
                      <div className="w-10 h-10 rounded-full bg-black text-white flex items-center justify-center group-hover:translate-x-1 transition-transform shadow-lg shadow-black/20"><ArrowRight size={18} /></div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </section>

        {/* SERVICES SECTION */}
        <section className="py-24 bg-secondary/10">
          <div className="container-custom px-4">
            <div data-aos="fade-up" className="text-center max-w-3xl mx-auto mb-20">
              <span className="text-accent font-black tracking-widest uppercase text-xs mb-3 block">{t('navbar.services')}</span>
              <h2 className="text-3xl md:text-5xl font-black mb-6 tracking-tighter">{t('home.help_title')}</h2>
              <p className="text-muted-foreground text-lg leading-relaxed italic">{t('home.help_desc')}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[
                { icon: <Globe />, title: "Web Development", desc: "Enterprise-grade web applications with modern tech stack." },
                { icon: <Smartphone />, title: "Mobile Development", desc: "High-performance native and cross-platform mobile apps." },
                { icon: <Database />, title: "Server Architecture", desc: "Secure, scalable, and robust backend infrastructure." }
              ].map((s, i) => (
                <div key={i} data-aos="fade-up" data-aos-delay={i * 100} className="p-10 rounded-[2.5rem] border border-border bg-white hover:bg-white hover:shadow-2xl transition-all group text-black">
                  <div className="w-14 h-14 mb-8 bg-black text-white flex items-center justify-center rounded-2xl group-hover:rotate-6 transition-transform shadow-xl shadow-black/10">{s.icon}</div>
                  <h3 className="text-2xl font-bold mb-4">{s.title}</h3>
                  <p className="text-muted-foreground leading-relaxed italic">{s.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA - IMPROVED */}
        <section className="py-20 px-4">
          <div className="max-w-5xl mx-auto relative rounded-[3rem] overflow-hidden bg-black py-20 px-8 md:px-16 text-center">
            <div className="absolute top-0 right-0 w-64 h-64 bg-accent/20 rounded-full blur-[80px] -mr-32 -mt-32" />
            <div className="relative z-10">
              <h2 className="text-3xl md:text-5xl font-black text-white tracking-tighter mb-8 leading-tight">
                {t('home.start_transform')}
              </h2>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                {!user ? (
                  <Link href="/register" className="px-10 py-4 bg-white text-black rounded-xl font-black text-xs uppercase tracking-widest hover:bg-accent hover:text-white transition-all">
                    {t('home.register_now')}
                  </Link>
                ) : (
                  <Link href="/products" className="px-10 py-4 bg-white text-black rounded-xl font-black text-xs uppercase tracking-widest hover:bg-accent hover:text-white transition-all">
                    Explore Products
                  </Link>
                )}
                <Link href="/contact" className="px-10 py-4 bg-transparent border-2 border-white/20 text-white rounded-xl font-black text-xs uppercase tracking-widest hover:bg-white/10 transition-all">
                  {t('home.contact_sales')}
                </Link>
              </div>
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
              <p className="text-muted-foreground text-sm leading-relaxed max-w-xs italic">{t('footer.desc')}</p>
            </div>
            <div>
              <h4 className="font-black text-xs uppercase tracking-widest text-black mb-8">{t('footer.company')}</h4>
              <ul className="space-y-4 text-sm font-bold text-muted-foreground">
                <li><Link href="/products" className="hover:text-black transition-colors">{t('navbar.products')}</Link></li>
                <li><Link href="/services" className="hover:text-black transition-colors">{t('navbar.services')}</Link></li>
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
                <li className="flex gap-3 leading-relaxed"><span>Cirebon, West Java, Indonesia</span></li>
                <li className="flex items-center gap-3"><span>08988289551</span></li>
                <li className="flex items-center gap-3"><span>arfzxcoder@gmail.com</span></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-border pt-8 text-center text-xs font-bold text-muted-foreground italic">
            <p>© 2026 ArfCoder. {t('footer.rights')}</p>
          </div>
        </div>
      </footer>
    </div>
  );
}