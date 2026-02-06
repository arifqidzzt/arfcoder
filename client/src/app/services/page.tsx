'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import Link from 'next/link';
import api from '@/lib/api';
import { CheckCircle2, ArrowRight, Code, Globe, Laptop, Database, Search, Layout } from 'lucide-react';
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

        {/* CTA */}
        <div className="mt-32 p-12 rounded-[3rem] bg-black text-white text-center relative overflow-hidden">
          <div className="absolute inset-0 bg-accent/10 opacity-50" />
          <h2 className="text-3xl md:text-5xl font-black mb-6 relative z-10">{t('home.start_transform')}</h2>
          <div className="flex flex-col sm:flex-row gap-4 justify-center relative z-10">
            <a href="https://wa.me/628988289551" className="px-10 py-5 bg-white text-black rounded-2xl font-black hover:scale-105 transition-all shadow-xl">{t('services.order_service')}</a>
            <a href="/contact" className="px-10 py-5 bg-transparent border-2 border-white/20 rounded-2xl font-black hover:bg-white/10 transition-all">{t('services.contact_admin')}</a>
          </div>
        </div>
      </main>
    </div>
  );
}
