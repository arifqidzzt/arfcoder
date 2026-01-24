'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useCartStore } from '@/store/useCartStore';
import { ShoppingCart, Search } from 'lucide-react';
import toast from 'react-hot-toast';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  discount: number;
  images: string[];
}

export default function ProductList() {
  const [products, setProducts] = useState<Product[]>([]);
  const addItem = useCartStore((state) => state.addItem);

  useEffect(() => {
    // In real app, fetch from API
    // Mock data for now
    setProducts([
      {
        id: '1',
        name: 'Premium UI Kit',
        description: 'Clean and modern UI components for your next project.',
        price: 450000,
        discount: 10,
        images: ['https://placehold.co/600x400/000000/FFFFFF?text=UI+Kit'],
      },
      {
        id: '2',
        name: 'Node.js Boilerplate',
        description: 'Scalable backend architecture with Express and Prisma.',
        price: 750000,
        discount: 0,
        images: ['https://placehold.co/600x400/000000/FFFFFF?text=Backend'],
      },
    ]);
  }, []);

  const handleAddToCart = (product: Product) => {
    addItem({
      id: product.id,
      name: product.name,
      price: product.price * (1 - product.discount / 100),
      quantity: 1,
      image: product.images[0],
    });
    toast.success(`${product.name} ditambahkan ke keranjang`);
  };

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <main className="max-w-7xl mx-auto px-8 py-12">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-12 gap-6">
          <div>
            <h1 className="text-4xl font-bold tracking-tight mb-2">Semua Produk</h1>
            <p className="text-gray-500">Temukan solusi digital terbaik untuk bisnis Anda.</p>
          </div>
          <div className="relative w-full md:w-80">
            <input 
              type="text" 
              placeholder="Cari produk..." 
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-none focus:outline-none focus:border-black transition-colors"
            />
            <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10">
          {products.map((product) => (
            <div key={product.id} className="group">
              <div className="aspect-[4/5] bg-gray-100 mb-6 overflow-hidden relative">
                <img 
                  src={product.images[0]} 
                  alt={product.name} 
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                {product.discount > 0 && (
                  <span className="absolute top-4 left-4 bg-black text-white text-[10px] px-2 py-1 font-bold">
                    -{product.discount}%
                  </span>
                )}
                <button 
                  onClick={() => handleAddToCart(product)}
                  className="absolute bottom-4 right-4 bg-white p-3 shadow-xl translate-y-4 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-300 hover:bg-black hover:text-white"
                >
                  <ShoppingCart size={20} />
                </button>
              </div>
              <h3 className="text-lg font-bold mb-1">{product.name}</h3>
              <p className="text-sm text-gray-500 mb-3 line-clamp-2">{product.description}</p>
              <div className="flex items-center space-x-2">
                <span className="font-bold">
                  Rp {(product.price * (1 - product.discount / 100)).toLocaleString('id-ID')}
                </span>
                {product.discount > 0 && (
                  <span className="text-sm text-gray-400 line-through">
                    Rp {product.price.toLocaleString('id-ID')}
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
