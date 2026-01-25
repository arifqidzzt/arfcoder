'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Navbar from '@/components/Navbar';
import { ArrowRight, Code, Palette, Rocket, CheckCircle, Mail, Phone, MapPin, Zap, Globe, Database, Smartphone } from 'lucide-react';
import api from '@/lib/api';

export default function Home() {
  const [featuredProducts, setFeaturedProducts] = useState([]);
  
  const languages = [
    "JavaScript", "TypeScript", "Python", "Go", "Java", "PHP", "Rust", "C++", "Swift", "Kotlin", "Ruby", "Dart"
  ];

  useEffect(() => {
    const fetchFeatured = async () => {
      try {
        const res = await api.get('/products');
        setFeaturedProducts(res.data.slice(0, 3)); 
      } catch (error) {
        console.error("Failed to fetch products");
      }
    };
    fetchFeatured();
  }, []);

  return (
    <div className="flex flex-col min-h-screen bg-background overflow-x-hidden w-full">
      <Navbar />

      <main className="flex-grow w-full">
        {/* HERO SECTION */}
        <section className="relative min-h-[90vh] flex items-center pt-24 pb-20 bg-grid-pattern">
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 -right-20 md:-right-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" />
            <div className="absolute bottom-1/4 -left-20 md:-left-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" style={{ animationDelay: '1s' }} />
          </div>

          <div className="container-custom relative z-10 w-full">
            <div className="max-w-4xl mx-auto text-center px-4">
              <div data-aos="fade-down" className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full mb-8 border border-border shadow-sm">
                <span className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-xs md:text-sm font-medium text-muted-foreground">
                  Official Partner for Digital Transformation
                </span>
              </div>

              <h1 data-aos="fade-up" data-aos-delay="100" className="text-4xl sm:text-5xl md:text-7xl font-bold tracking-tight mb-8 leading-[1.1]">
                Solusi Digital untuk<br />
                <span className="text-gradient block mt-2 pb-2">Pertumbuhan Bisnis</span>
              </h1>

              <p data-aos="fade-up" data-aos-delay="200" className="text-base md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10 leading-relaxed">
                Kami mengubah ide kompleks menjadi produk digital yang simpel, elegan, dan berdampak besar bagi bisnis Anda.
              </p>

              <div data-aos="fade-up" data-aos-delay="300" className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-20 w-full px-4">
                <Link href="/products" className="btn-hero-primary group w-full sm:w-auto">
                  <span>Belanja Produk</span>
                  <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
                </Link>
                <Link href="/services" className="btn-hero-secondary w-full sm:w-auto">
                  Konsultasi Gratis
                </Link>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 text-left">
                <div data-aos="fade-up" data-aos-delay="400" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <Zap className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">Lightning Fast</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    Optimasi performa maksimal untuk load time di bawah 1 detik.
                  </p>
                </div>

                <div data-aos="fade-up" data-aos-delay="500" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <CheckCircle className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">SEO Optimized</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    Struktur kode yang ramah mesin pencari untuk ranking terbaik.
                  </p>
                </div>

                <div data-aos="fade-up" data-aos-delay="600" className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <Code className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">Scalable</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
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
            <ul className="flex items-center justify-center md:justify-start [&_li]:mx-8 animate-marquee text-muted-foreground font-bold text-xl uppercase tracking-widest opacity-50">
              {languages.map((tech, i) => <li key={i} className="whitespace-nowrap">{tech}</li>)}
              {languages.map((tech, i) => <li key={`dup-${i}`} className="whitespace-nowrap">{tech}</li>)}
            </ul>
          </div>
        </section>

        {/* PREVIEW PRODUCTS SECTION */}
        <section className="py-24 bg-secondary/20">
          <div className="container-custom">
            <div data-aos="fade-right" className="flex flex-col md:flex-row justify-between items-end mb-12 gap-4">
              <div>
                <span className="text-accent font-bold tracking-wider uppercase text-sm mb-2 block">Katalog</span>
                <h2 className="text-3xl md:text-4xl font-bold tracking-tight">Produk Terbaru</h2>
              </div>
              <Link href="/products" className="inline-flex items-center justify-center px-6 py-3 rounded-lg border border-border bg-white hover:bg-gray-50 transition-colors font-medium">
                Lihat Semua Produk
              </Link>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredProducts.length === 0 ? (
                <div className="col-span-3 text-center py-10 text-gray-400 italic">Belum ada produk di database.</div>
              ) : (
                featuredProducts.map((product: any, idx) => (
                  <Link href={`/products/${product.id}`} key={product.id} data-aos="fade-up" data-aos-delay={idx * 100} className="group cursor-pointer bg-white rounded-2xl p-4 border border-border hover:border-accent/30 transition-all hover:shadow-lg">
                    <div className="bg-gray-100 rounded-xl aspect-[16/10] mb-5 overflow-hidden relative">
                      <img src={product.images[0] || 'https://placehold.co/600x400'} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                    </div>
                    <div className="px-2">
                      <h3 className="text-lg font-bold mb-1 group-hover:text-accent transition-colors">{product.name}</h3>
                      <p className="text-muted-foreground text-xs mb-3 line-clamp-1">{product.description}</p>
                      <div className="flex justify-between items-center">
                        <span className="font-bold">Rp {product.price.toLocaleString('id-ID')}</span>
                        <div className="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center"><ArrowRight size={14} /></div>
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
          <div className="container-custom">
            <div data-aos="fade-up" className="text-center max-w-2xl mx-auto mb-16">
              <span className="text-accent font-bold tracking-wider uppercase text-sm mb-2 block">Layanan Kami</span>
              <h2 className="text-3xl md:text-4xl font-bold mb-4">Apa yang Bisa Kami Bantu?</h2>
              <p className="text-muted-foreground">
                Dari konsep hingga peluncuran, kami menangani seluruh siklus pengembangan produk digital Anda.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[
                { icon: <Globe />, title: "Web Development", desc: "Website performa tinggi dengan teknologi terbaru." },
                { icon: <Smartphone />, title: "Mobile Apps", desc: "Aplikasi Android & iOS yang responsif." },
                { icon: <Database />, title: "Backend System", desc: "Arsitektur server yang aman dan scalable." }
              ].map((s, i) => (
                <div key={i} data-aos="fade-up" data-aos-delay={i * 100} className="p-8 rounded-2xl border border-border bg-secondary/10 hover:bg-white hover:shadow-xl transition-all">
                  <div className="w-12 h-12 mb-6 bg-black text-white flex items-center justify-center rounded-xl">{s.icon}</div>
                  <h3 className="text-xl font-bold mb-3">{s.title}</h3>
                  <p className="text-muted-foreground text-sm leading-relaxed">{s.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="py-24 relative overflow-hidden bg-black text-white">
          <div className="container-custom relative z-10 text-center">
            <h2 data-aos="zoom-in" className="text-3xl md:text-5xl font-bold mb-6">Mulai Transformasi Digital Anda</h2>
            <div data-aos="fade-up" data-aos-delay="200" className="flex flex-col sm:flex-row gap-4 justify-center mt-10">
              <Link href="/register" className="px-8 py-4 bg-white text-black rounded-xl font-bold hover:bg-gray-100 transition-colors">Daftar Sekarang</Link>
              <Link href="/contact" className="px-8 py-4 bg-transparent border border-white/20 text-white rounded-xl font-bold hover:bg-white/10 transition-colors">Hubungi Sales</Link>
            </div>
          </div>
        </section>
      </main>

      {/* FOOTER */}
      <footer className="bg-white pt-20 pb-12 border-t border-border">
        <div className="container-custom">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
            <div className="col-span-1 md:col-span-1">
              <span className="text-2xl font-bold tracking-tighter block mb-6">ARFCODER</span>
              <p className="text-muted-foreground text-sm leading-relaxed">
                Partner digital terpercaya untuk transformasi bisnis Anda di Cirebon dan seluruh Indonesia.
              </p>
            </div>
            <div>
              <h4 className="font-bold mb-6">Perusahaan</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li><Link href="/services">Layanan</Link></li>
                <li><Link href="/products">Produk</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-6">Dukungan</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li><Link href="/terms" className="hover:text-accent">Syarat & Ketentuan</Link></li>
                <li><Link href="/privacy" className="hover:text-accent">Kebijakan Privasi</Link></li>
                <li><Link href="/refund-policy" className="hover:text-accent">Kebijakan Refund</Link></li>
                <li><Link href="/faq" className="hover:text-accent">Pusat Bantuan</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-6">Hubungi Kami</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li className="flex items-start gap-3"><MapPin className="text-accent w-5 h-5 shrink-0"/> <span>Jl.Kebun Baru Indah Blok Puhun Dusun 4 Kabupaten Cirebon</span></li>
                <li className="flex items-center gap-3"><Phone className="text-accent w-5 h-5 shrink-0"/> <span>08988289551</span></li>
                <li className="flex items-center gap-3"><Mail className="text-accent w-5 h-5 shrink-0"/> <span>arfzxcoder@gmail.com</span></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-border pt-8 text-center text-xs text-muted-foreground">© 2026 ArfCoder. All rights reserved.</div>
        </div>
      </footer>
    </div>
  );
}
