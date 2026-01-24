import Link from 'next/link';
import Navbar from '@/components/Navbar';
import { ArrowRight, Code, Palette, Rocket, CheckCircle, Mail, Phone, MapPin, Zap, Globe, Database, Smartphone } from 'lucide-react';

export default function Home() {
  const techStack = [
    "JavaScript", "TypeScript", "Python", "Go", "Java", "PHP", "Rust", "C++", "Swift", "Kotlin", "Ruby", "Dart"
  ];

  const featuredServices = [
    {
      icon: <Globe className="w-6 h-6" />,
      title: "Web Development",
      description: "Website performa tinggi dengan teknologi terbaru untuk representasi digital bisnis Anda."
    },
    {
      icon: <Smartphone className="w-6 h-6" />,
      title: "Mobile Apps",
      description: "Aplikasi Android & iOS native atau cross-platform yang responsif dan user-friendly."
    },
    {
      icon: <Database className="w-6 h-6" />,
      title: "Backend System",
      description: "Arsitektur server yang aman, scalable, dan efisien untuk menangani jutaan request."
    }
  ];

  return (
    <div className="flex flex-col min-h-screen bg-background overflow-x-hidden w-full">
      <Navbar />

      <main className="flex-grow w-full">
        {/* HERO SECTION */}
        <section className="relative min-h-[90vh] flex items-center pt-24 pb-20 bg-grid-pattern">
          {/* Background Decorative Blobs (Fixed Overflow) */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 -right-20 md:-right-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" />
            <div className="absolute bottom-1/4 -left-20 md:-left-32 w-64 h-64 md:w-96 md:h-96 bg-accent/5 rounded-full blur-3xl animate-pulse opacity-70" style={{ animationDelay: '1s' }} />
          </div>

          <div className="container-custom relative z-10 w-full">
            <div className="max-w-4xl mx-auto text-center px-4">
              {/* Badge */}
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full mb-8 animate-fade-in border border-border shadow-sm">
                <span className="w-2 h-2 bg-accent rounded-full animate-pulse" />
                <span className="text-xs md:text-sm font-medium text-muted-foreground">
                  Official Partner for Digital Transformation
                </span>
              </div>

              {/* Heading */}
              <h1 className="text-4xl sm:text-5xl md:text-7xl font-bold tracking-tight mb-8 animate-slide-up leading-[1.1] md:leading-[1.1]">
                Solusi Digital untuk<br />
                <span className="text-gradient block mt-2 pb-2">Pertumbuhan Bisnis</span>
              </h1>

              {/* Description */}
              <p className="text-base md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10 animate-slide-up [animation-delay:200ms] leading-relaxed px-4">
                Kami mengubah ide kompleks menjadi produk digital yang simpel, elegan, dan berdampak besar bagi bisnis Anda.
              </p>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-20 animate-slide-up [animation-delay:300ms] w-full px-4">
                <Link href="/products" className="btn-hero-primary group w-full sm:w-auto">
                  <span>Lihat Produk</span>
                  <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
                </Link>
                <Link href="/services" className="btn-hero-secondary w-full sm:w-auto">
                  Konsultasi Gratis
                </Link>
              </div>

              {/* Features Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 animate-slide-up [animation-delay:400ms] text-left">
                <div className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <Zap className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">Lightning Fast</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    Optimasi performa maksimal untuk load time di bawah 1 detik.
                  </p>
                </div>

                <div className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
                  <div className="w-10 h-10 rounded-lg bg-black text-white flex items-center justify-center mb-4">
                    <CheckCircle className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-bold mb-2">SEO Optimized</h3>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    Struktur kode yang ramah mesin pencari untuk ranking terbaik.
                  </p>
                </div>

                <div className="flex flex-col p-6 rounded-2xl bg-white border border-border shadow-soft hover:shadow-elevated transition-all hover:-translate-y-1">
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
            <ul className="flex items-center justify-center md:justify-start [&_li]:mx-8 [&_img]:max-w-none animate-marquee text-muted-foreground font-bold text-xl uppercase tracking-widest opacity-50">
              {techStack.map((tech, i) => (
                <li key={i} className="whitespace-nowrap">{tech}</li>
              ))}
              {/* Duplicate for seamless loop */}
              {techStack.map((tech, i) => (
                <li key={`dup-${i}`} className="whitespace-nowrap">{tech}</li>
              ))}
            </ul>
          </div>
        </section>

        {/* SERVICES SECTION */}
        <section className="py-24 bg-white">
          <div className="container-custom">
            <div className="text-center max-w-2xl mx-auto mb-16">
              <span className="text-accent font-bold tracking-wider uppercase text-sm mb-2 block">Layanan Kami</span>
              <h2 className="text-3xl md:text-4xl font-bold mb-4">Apa yang Bisa Kami Bantu?</h2>
              <p className="text-muted-foreground">
                Dari konsep hingga peluncuran, kami menangani seluruh siklus pengembangan produk digital Anda.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredServices.map((service, idx) => (
                <div key={idx} className="group p-8 rounded-2xl border border-border hover:border-accent/50 bg-secondary/20 hover:bg-white transition-all hover:shadow-elevated">
                  <div className="w-12 h-12 rounded-xl bg-secondary group-hover:bg-accent group-hover:text-white flex items-center justify-center mb-6 transition-colors text-foreground">
                    {service.icon}
                  </div>
                  <h3 className="text-xl font-bold mb-3">{service.title}</h3>
                  <p className="text-muted-foreground mb-6 leading-relaxed">
                    {service.description}
                  </p>
                  <Link href="/services" className="inline-flex items-center text-sm font-bold text-foreground group-hover:text-accent transition-colors">
                    Pelajari Lebih Lanjut <ArrowRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* PREVIEW PRODUCTS SECTION */}
        <section className="py-24 bg-secondary/20">
          <div className="container-custom">
            <div className="flex flex-col md:flex-row justify-between items-end mb-12 gap-4">
              <div>
                <span className="text-accent font-bold tracking-wider uppercase text-sm mb-2 block">Katalog</span>
                <h2 className="text-3xl md:text-4xl font-bold tracking-tight">Produk Digital Premium</h2>
              </div>
              <Link href="/products" className="inline-flex items-center justify-center px-6 py-3 rounded-lg border border-border bg-white hover:bg-gray-50 transition-colors font-medium">
                Lihat Semua Produk
              </Link>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[1, 2, 3].map((i) => (
                <div key={i} className="group cursor-pointer bg-white rounded-2xl p-4 border border-border hover:border-accent/30 transition-all hover:shadow-lg">
                  <div className="bg-gray-100 rounded-xl aspect-[16/10] mb-5 overflow-hidden relative">
                    <div className="absolute inset-0 flex items-center justify-center text-gray-400">
                      <span className="text-sm font-medium">Product Image Placeholder</span>
                    </div>
                    {/* Hover Overlay */}
                    <div className="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity" />
                  </div>
                  <div className="px-2 pb-2">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h3 className="text-lg font-bold mb-1 group-hover:text-accent transition-colors">SaaS Starter Kit v{i}.0</h3>
                        <p className="text-muted-foreground text-xs">React, Node.js, Prisma</p>
                      </div>
                      <span className="bg-secondary px-2 py-1 rounded text-xs font-bold">Rp 1.5jt</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA SECTION */}
        <section className="py-24 relative overflow-hidden bg-black text-white">
          <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#4f46e5_1px,transparent_1px)] [background-size:16px_16px]"></div>
          <div className="container-custom relative z-10 text-center">
            <h2 className="text-3xl md:text-5xl font-bold mb-6">Mulai Transformasi Digital Anda</h2>
            <p className="text-lg text-gray-400 max-w-2xl mx-auto mb-10">
              Jangan biarkan ide cemerlang Anda hanya menjadi wacana. Mari wujudkan bersama tim engineer terbaik kami.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/register" className="px-8 py-4 bg-white text-black rounded-xl font-bold hover:bg-gray-100 transition-colors">
                Daftar Sekarang
              </Link>
              <Link href="/contact" className="px-8 py-4 bg-transparent border border-white/20 text-white rounded-xl font-bold hover:bg-white/10 transition-colors">
                Hubungi Sales
              </Link>
            </div>
          </div>
        </section>
      </main>

      {/* FOOTER */}
      <footer className="bg-white pt-20 pb-12 border-t border-border">
        <div className="container-custom">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-16">
            <div className="col-span-1 md:col-span-2 lg:col-span-1">
              <span className="text-2xl font-bold tracking-tighter block mb-6">ARFCODER</span>
              <p className="text-muted-foreground text-sm leading-relaxed mb-6">
                Kami membangun ekosistem digital yang berkelanjutan, aman, dan berorientasi pada hasil nyata untuk bisnis Anda.
              </p>
              <div className="flex space-x-4">
                {/* Social Placeholder */}
                <div className="w-8 h-8 bg-secondary rounded-full flex items-center justify-center hover:bg-black hover:text-white transition-colors cursor-pointer">X</div>
                <div className="w-8 h-8 bg-secondary rounded-full flex items-center justify-center hover:bg-black hover:text-white transition-colors cursor-pointer">In</div>
                <div className="w-8 h-8 bg-secondary rounded-full flex items-center justify-center hover:bg-black hover:text-white transition-colors cursor-pointer">Gh</div>
              </div>
            </div>
            
            <div>
              <h4 className="font-bold mb-6 text-foreground">Perusahaan</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li><Link href="/about" className="hover:text-accent transition-colors">Tentang Kami</Link></li>
                <li><Link href="/careers" className="hover:text-accent transition-colors">Karir</Link></li>
                <li><Link href="/blog" className="hover:text-accent transition-colors">Blog Tech</Link></li>
                <li><Link href="/partners" className="hover:text-accent transition-colors">Partnership</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold mb-6 text-foreground">Dukungan</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li><Link href="/faq" className="hover:text-accent transition-colors">Pusat Bantuan</Link></li>
                <li><Link href="/status" className="hover:text-accent transition-colors">System Status</Link></li>
                <li><Link href="/terms" className="hover:text-accent transition-colors">Syarat & Ketentuan</Link></li>
                <li><Link href="/privacy" className="hover:text-accent transition-colors">Kebijakan Privasi</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold mb-6 text-foreground">Hubungi Kami</h4>
              <ul className="space-y-4 text-sm text-muted-foreground">
                <li className="flex items-start space-x-3">
                  <MapPin className="w-5 h-5 flex-shrink-0 mt-0.5 text-accent" />
                  <span>Jl.Kebun Baru Indah Blok Puhun Dusun 4 Kabupaten Cirebon</span>
                </li>
                <li className="flex items-center space-x-3">
                  <Phone className="w-5 h-5 flex-shrink-0 text-accent" />
                  <span>08988289551</span>
                </li>
                <li className="flex items-center space-x-3">
                  <Mail className="w-5 h-5 flex-shrink-0 text-accent" />
                  <span>arfzxcoder@gmail.com</span>
                </li>
              </ul>
            </div>
          </div>

          <div className="border-t border-border pt-8 flex flex-col md:flex-row justify-between items-center text-xs text-muted-foreground">
            <p>© 2026 ArfCoder Digital. All rights reserved.</p>
            <div className="flex space-x-6 mt-4 md:mt-0">
              <span className="flex items-center gap-2"><div className="w-2 h-2 rounded-full bg-green-500"></div> All Systems Operational</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
