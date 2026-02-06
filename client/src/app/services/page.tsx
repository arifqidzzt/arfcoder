'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { ArrowRight, Code, Palette, Rocket, Smartphone, Globe, ShieldCheck, Mail, Phone, MessageSquare } from 'lucide-react';
import api from '@/lib/api';
import { useTranslation } from '@/lib/i18n';

export default function ServicesPage() {
  const { t } = useTranslation();
  const [services, setServices] = useState([]);

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const res = await api.get('/products/services');
        setServices(res.data);
      } catch (error) {
        console.error("Failed to fetch services");
      }
    };
    fetchServices();
  }, []);

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-4 sm:px-8 py-24">
        <div data-aos="fade-up" className="text-center max-w-3xl mx-auto mb-20">
          <h1 className="text-4xl md:text-6xl font-black tracking-tighter mb-6 text-black">{t('services.title')}</h1>
          <p className="text-xl text-gray-500 leading-relaxed">{t('services.desc')}</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {services.map((service: any, idx) => (
            <div key={service.id} data-aos="fade-up" data-aos-delay={idx * 100} className="group p-8 rounded-[2.5rem] border border-gray-100 bg-gray-50/50 hover:bg-white hover:shadow-2xl transition-all duration-500 flex flex-col">
              <div className="w-14 h-14 bg-black text-white rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 group-hover:rotate-6 transition-transform shadow-xl shadow-black/10">
                {service.icon === 'Code' ? <Code /> : service.icon === 'Palette' ? <Palette /> : <Globe />}
              </div>
              <h3 className="text-2xl font-bold mb-4">{service.title}</h3>
              <p className="text-gray-500 mb-8 leading-relaxed flex-grow">{service.description}</p>
              <div className="pt-6 border-t border-gray-100">
                <p className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">Mulai dari</p>
                <div className="flex items-center justify-between">
                  <span className="text-2xl font-black">Rp {Number(service.price).toLocaleString()}</span>
                  <a href="https://wa.me/628988289551" target="_blank" className="w-12 h-12 bg-white border border-gray-100 rounded-full flex items-center justify-center hover:bg-black hover:text-white transition-all shadow-sm">
                    <ArrowRight size={20} />
                  </a>
                </div>
              </div>
            </div>
          ))}
        </div>

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
