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
        <section className="relative min-h-[90vh] flex items-center pt-20 pb-16 md:pt-24 md:pb-20 bg-grid-pattern">
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 -right-20 md:-right-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" />
            <div className="absolute bottom-1/4 -left-20 md:-left-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" style={{ animationDelay: '1s' }} />
          </div>

          <div className="container-custom relative z-10 w-full px-4">
            <div className="max-w-4xl mx-auto text-center">
              <div data-aos="fade-down" className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full mb-8 border border-border shadow-sm">
                <span className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-[10px] sm:text-xs md:text-sm font-medium text-muted-foreground uppercase tracking-widest">
                  Official Partner for Digital Transformation
                </span>
              </div>

              <h1 data-aos="fade-up" data-aos-delay="100" className="text-3xl sm:text-5xl md:text-7xl font-black tracking-tighter mb-8 leading-[1.1]">
                {t('home.hero_title_part1')}<br />
                <span className="text-gradient block mt-2 pb-2">{t('home.hero_title_part2')}</span>
              </h1>

              <p data-aos="fade-up" data-aos-delay="200" className="text-sm sm:text-base md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10 leading-relaxed">
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
        <section className="py-24 border-y border-border bg-secondary/30 overflow-hidden">
          <div className="w-full inline-flex flex-nowrap overflow-hidden [mask-image:_linear-gradient(to_right,transparent_0,_black_128px,_black_calc(100%-128px),transparent_100%)]">
            <ul className="flex items-center justify-center md:justify-start [&_li]:mx-20 animate-marquee text-muted-foreground font-black text-xl uppercase tracking-[0.3em] opacity-80">
              {languages.map((tech, i) => (
                <li key={i} className="whitespace-nowrap flex flex-col items-center gap-6">
                  <img 
                    src={tech === "Java" 
                      ? "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/java/java-original.svg" 
                      : `https://cdn.simpleicons.org/${techLogos[tech] || tech.toLowerCase()}/gray`} 
                    alt="" 
                    className={`w-24 h-24 object-contain transition-opacity ${tech === "Java" ? "" : "opacity-60 hover:opacity-100"}`} 
                  />
                  <span className="text-2xl">{tech}</span>
                </li>
              ))}
              {languages.map((tech, i) => (
                <li key={`dup-${i}`} className="whitespace-nowrap flex flex-col items-center gap-6">
                  <img 
                    src={tech === "Java" 
                      ? "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/java/java-original.svg" 
                      : `https://cdn.simpleicons.org/${techLogos[tech] || tech.toLowerCase()}/gray`} 
                    alt="" 
                    className={`w-24 h-24 object-contain transition-opacity ${tech === "Java" ? "" : "opacity-60 hover:opacity-100"}`} 
                  />
                  <span className="text-2xl">{tech}</span>
                </li>
              ))}
            </ul>
          </div>
        </section>

        {/* LATEST PRODUCTS - CLEAN DESIGN */}
        <section className="py-24 bg-white relative">
          <div className="container-custom px-4 relative z-10">
            <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-6">
              <div data-aos="fade-right">
                <span className="text-accent font-black tracking-widest uppercase text-xs mb-3 block">{t('navbar.products')}</span>
                <h2 className="text-4xl md:text-6xl font-black tracking-tighter">
                  {t('home.latest_products')}
                </h2>
              </div>
              <Link href="/products" className="btn-hero-secondary text-sm px-10 py-4" data-aos="fade-left">
                {t('home.view_all')}
              </Link>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredProducts.map((product: any, idx) => (
                <Link href={`/products/${product.id}`} key={product.id} data-aos="fade-up" data-aos-delay={idx * 100} className="group bg-white rounded-[2.5rem] p-6 border border-border hover:border-accent/30 transition-all hover:shadow-2xl flex flex-col">
                  <div className="bg-gray-50 rounded-[1.5rem] aspect-[16/10] mb-6 overflow-hidden relative shadow-inner">
                    <img src={product.images[0] || 'https://placehold.co/600x400'} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" alt="" />
                    
                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity duration-500 flex items-center justify-center gap-4">
                      <button 
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          handleAddToCart(e, product);
                        }}
                        className="w-14 h-14 bg-white text-black rounded-full flex items-center justify-center hover:bg-accent hover:text-white transition-all scale-75 group-hover:scale-100 duration-500"
                      >
                        <ShoppingCart size={24} />
                      </button>
                    </div>
                  </div>
                  
                  <div className="flex-grow">
                    <h3 className="text-2xl font-black mb-2 group-hover:text-accent transition-colors">{product.name}</h3>
                    <p className="text-muted-foreground text-sm line-clamp-2 leading-relaxed mb-6 italic">{product.description}</p>
                    <div className="flex justify-between items-center mt-auto">
                      <span className="font-black text-2xl">Rp {product.price.toLocaleString('id-ID')}</span>
                      <div className="w-12 h-12 rounded-full bg-black text-white flex items-center justify-center group-hover:translate-x-2 transition-transform shadow-lg"><ArrowRight size={20} /></div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </section>

        {/* SERVICES SECTION */}
        {/* ... (Previous services section remains but could be slightly adjusted) ... */}

        {/* CTA - REDESIGNED */}
        <section className="py-20 px-4 md:px-10">
          <div className="max-w-7xl mx-auto relative rounded-[4rem] overflow-hidden bg-black py-24 px-8 md:py-32 md:px-16">
            <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-accent/20 rounded-full blur-[120px] -mr-64 -mt-64 animate-pulse" />
            <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-blue-500/10 rounded-full blur-[120px] -ml-64 -mb-64 animate-pulse" style={{ animationDelay: '1s' }} />
            
            <div className="relative z-10 text-center flex flex-col items-center">
              <div className="w-20 h-20 bg-white/10 backdrop-blur-md rounded-3xl flex items-center justify-center mb-10 border border-white/20 rotate-6 hover:rotate-0 transition-transform duration-500">
                <Zap className="w-10 h-10 text-accent fill-accent" />
              </div>
              
              <h2 className="text-4xl md:text-7xl font-black text-white tracking-tighter leading-[0.9] mb-10 max-w-4xl">
                {t('home.start_transform').split(' ').slice(0, -1).join(' ')} <br/>
                <span className="text-gradient">{t('home.start_transform').split(' ').slice(-1)}</span>
              </h2>
              
              <p className="text-gray-400 text-lg md:text-xl max-w-2xl mb-12 font-medium italic">
                {t('home.help_desc')}
              </p>

              <div className="flex flex-col sm:flex-row gap-6 w-full sm:w-auto">
                <Link href="/register" className="px-12 py-6 bg-white text-black rounded-2xl font-black text-sm uppercase tracking-[0.2em] hover:bg-accent hover:text-white transition-all hover:scale-105 shadow-[0_20px_50px_rgba(255,255,255,0.1)]">
                  {t('home.register_now')}
                </Link>
                <Link href="/contact" className="px-12 py-6 bg-transparent border-2 border-white/20 text-white rounded-2xl font-black text-sm uppercase tracking-[0.2em] hover:bg-white/10 transition-all">
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