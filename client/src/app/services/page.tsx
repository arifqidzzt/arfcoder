import Navbar from '@/components/Navbar';
import Link from 'next/link';
import api from '@/lib/api';
import { CheckCircle2, ArrowRight } from 'lucide-react';

export default function ServicesPage() {
  const [services, setServices] = useState<any[]>([]);

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const res = await api.get('/products/services');
        setServices(res.data);
      } catch (error) {
        console.error('Failed to fetch services');
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
        <div className="text-center mb-16">
          <h1 className="text-5xl font-bold mb-4 tracking-tight">Layanan Profesional</h1>
          <p className="text-gray-500 max-w-2xl mx-auto text-lg">
            Solusi teknologi kustom yang dirancang khusus untuk mempercepat pertumbuhan bisnis Anda.
          </p>
        </div>

        {loading ? (
          <div className="text-center py-20 text-gray-400">Memuat layanan...</div>
        ) : services.length === 0 ? (
          <div className="text-center py-20 text-gray-400 italic border border-dashed rounded-2xl">Belum ada layanan yang ditambahkan oleh admin.</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {services.map((service, index) => (
              <div key={index} className="p-10 border border-gray-100 rounded-3xl hover:shadow-2xl transition-all hover:-translate-y-2 bg-white group relative overflow-hidden">
                <div className="absolute top-0 right-0 w-32 h-32 bg-accent/5 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500" />
                <div className="mb-8 p-4 bg-secondary rounded-2xl w-fit group-hover:bg-black group-hover:text-white transition-colors">
                  <DynamicIcon name={service.icon} />
                </div>
                <h3 className="text-2xl font-bold mb-4">{service.title}</h3>
                <p className="text-gray-500 mb-8 text-sm leading-relaxed">
                  {service.description}
                </p>
                <div className="pt-6 border-t border-gray-50 flex justify-between items-center">
                  <span className="font-bold text-accent">{service.price}</span>
                  <Icons.ArrowRight className="text-gray-300 group-hover:text-black group-hover:translate-x-2 transition-all" />
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}