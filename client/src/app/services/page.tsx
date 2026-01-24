'use client';

import Navbar from '@/components/Navbar';
import { Code, Smartphone, Database, Search, Layout, Server } from 'lucide-react';

export default function ServicesPage() {
  const services = [
    {
      icon: <Code size={40} />,
      title: "Custom Web Development",
      description: "Website kustom dengan teknologi terbaru (Next.js, React) yang cepat dan SEO-friendly.",
      price: "Mulai Rp 3.000.000"
    },
    {
      icon: <Smartphone size={40} />,
      title: "Mobile App Development",
      description: "Aplikasi Android & iOS menggunakan React Native atau Flutter.",
      price: "Mulai Rp 5.000.000"
    },
    {
      icon: <Database size={40} />,
      title: "Backend & API Integration",
      description: "Pengembangan sistem backend yang aman dan skalabel dengan Node.js & Go.",
      price: "Mulai Rp 2.500.000"
    },
    {
      icon: <Layout size={40} />,
      title: "UI/UX Design",
      description: "Desain antarmuka yang modern, estetis, dan mudah digunakan (Figma).",
      price: "Mulai Rp 1.500.000"
    },
    {
      icon: <Server size={40} />,
      title: "VPS & Cloud Setup",
      description: "Konfigurasi server AWS, DigitalOcean, atau Google Cloud untuk aplikasi Anda.",
      price: "Mulai Rp 500.000"
    },
    {
      icon: <Search size={40} />,
      title: "SEO Optimization",
      description: "Optimasi website agar muncul di halaman pertama Google.",
      price: "Mulai Rp 1.000.000"
    }
  ];

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-8 py-16">
        <div className="text-center mb-16">
          <h1 className="text-4xl font-bold mb-4">Layanan Kami</h1>
          <p className="text-gray-500 max-w-2xl mx-auto">
            Kami menyediakan solusi digital komprehensif untuk membantu bisnis Anda berkembang di era teknologi.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {services.map((service, index) => (
            <div key={index} className="p-8 border border-gray-100 rounded-2xl hover:shadow-lg transition-all hover:-translate-y-1 bg-white group">
              <div className="mb-6 p-4 bg-gray-50 rounded-xl w-fit group-hover:bg-black group-hover:text-white transition-colors">
                {service.icon}
              </div>
              <h3 className="text-xl font-bold mb-3">{service.title}</h3>
              <p className="text-gray-500 mb-6 text-sm leading-relaxed">
                {service.description}
              </p>
              <div className="pt-6 border-t border-gray-50">
                <span className="text-sm font-bold text-blue-600">{service.price}</span>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
