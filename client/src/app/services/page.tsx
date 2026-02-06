'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import api from '@/lib/api';
import { CheckCircle2, ArrowRight, Code, Globe, Laptop, Database, Search, Layout, Zap } from 'lucide-react';
import { useTranslation } from '@/lib/i18n';

const Icons = { Code, Globe, Laptop, Database, Search, Layout, ArrowRight };

export default function ServicesPage() {
  const { t } = useTranslation();
  const [services, setServices] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const res = await api.get('/products/services');
        setServices(res.data);
      } catch (error) {
        console.error('Failed to fetch services');
      } finally {
        setLoading(false);
      }
    };
    fetchServices();
  }, []);

  const DynamicIcon = ({ name }: { name: string }) => {
    const IconComponent = (Icons as any)[name] || Icons.Code;
    return <IconComponent size={40} />;
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-8 py-24 pt-32">
        <div data-aos="fade-up" className="text-center mb-16">
          <h1 className="text-5xl font-black mb-4 tracking-tighter text-black">{t('services.title')}</h1>
          <p className="text-gray-500 max-w-2xl mx-auto text-lg leading-relaxed">
            {t('services.desc')}
          </p>
        </div>

        {loading ? (
          <div className="text-center py-20 text-gray-400">{t('common.loading')}</div>
        ) : services.length === 0 ? (
          <div className="text-center py-20 text-gray-400 italic border border-dashed rounded-[2rem]">{t('products.empty')}</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {services.map((service, index) => (
              <div key={index} data-aos="fade-up" data-aos-delay={index * 100} className="p-10 border border-gray-100 rounded-[2.5rem] hover:shadow-2xl transition-all hover:-translate-y-2 bg-white group relative overflow-hidden">
                <div className="absolute top-0 right-0 w-32 h-32 bg-accent/5 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500" />
                <div className="mb-8 p-5 bg-secondary/50 rounded-2xl w-fit group-hover:bg-black group-hover:text-white transition-all duration-300">
                  <DynamicIcon name={service.icon} />
                </div>
                <h3 className="text-2xl font-black mb-4 tracking-tight">{service.title}</h3>
                <p className="text-gray-500 mb-8 text-sm leading-relaxed flex-grow">
                  {service.description}
                </p>
                <div className="pt-6 border-t border-gray-100 flex justify-between items-center">
                  <span className="font-black text-xl text-accent">
                    {isNaN(Number(service.price)) ? service.price : `Rp ${Number(service.price).toLocaleString()}`}
                  </span>
                  <a href="https://wa.me/628988289551" target="_blank" className="w-12 h-12 bg-gray-50 rounded-full flex items-center justify-center group-hover:bg-black group-hover:text-white transition-all shadow-sm">
                    <Icons.ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
                  </a>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* CTA - REDESIGNED */}
        <section className="mt-32 relative rounded-[4rem] overflow-hidden bg-black py-24 px-8 md:py-32 md:px-16">
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
              <a href="https://wa.me/628988289551" className="px-12 py-6 bg-white text-black rounded-2xl font-black text-sm uppercase tracking-[0.2em] hover:bg-accent hover:text-white transition-all hover:scale-105 shadow-[0_20px_50px_rgba(255,255,255,0.1)]">
                {t('services.order_service')}
              </a>
              <a href="/contact" className="px-12 py-6 bg-transparent border-2 border-white/20 text-white rounded-2xl font-black text-sm uppercase tracking-[0.2em] hover:bg-white/10 transition-all">
                {t('services.contact_admin')}
              </a>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
