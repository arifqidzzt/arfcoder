import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api from '@/lib/api';
import { useAuthStore } from './useAuthStore';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  image?: string;
  paymentMethods?: string[];
}

interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => Promise<void>;
  removeItem: (id: string) => Promise<void>;
  updateQuantity: (id: string, quantity: number) => Promise<void>;
  clearCart: () => void;
  fetchCart: () => Promise<void>;
  total: () => number;
}

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      items: [],
      
      fetchCart: async () => {
        const { token } = useAuthStore.getState();
        if (!token) return;
        try {
          const res = await api.get('/user/cart');
          // Map DB models to Store interface with DISCOUNTED PRICE
          const mappedItems = res.data.map((ci: any) => ({
            id: ci.product.id,
            name: ci.product.name,
            // CALC DISCOUNT: Original * (1 - Disc/100)
            price: ci.product.price * (1 - (ci.product.discount || 0) / 100),
            quantity: ci.quantity,
            image: ci.product.images?.[0],
            paymentMethods: ci.product.paymentMethods || []
          }));
          set({ items: mappedItems });
        } catch (e) { console.error('Failed to sync cart', e); }
      },

      addItem: async (item) => {
        const { token } = useAuthStore.getState();
        if (token) {
          await api.post('/user/cart', { productId: item.id, quantity: item.quantity });
        }

        const currentItems = get().items;
        const existingItem = currentItems.find((i) => i.id === item.id);
        if (existingItem) {
          set({
            items: currentItems.map((i) =>
              i.id === item.id ? { ...i, quantity: i.quantity + item.quantity } : i
            ),
          });
        } else {
          set({ items: [...currentItems, item] });
        }
      },

      removeItem: async (id) => {
        const { token } = useAuthStore.getState();
        if (token) {
          await api.delete(`/user/cart/${id}`);
          get().fetchCart(); // Refresh from server
        } else {
          set({ items: get().items.filter((i) => i.id !== id) });
        }
      },

      updateQuantity: async (id, quantity) => {
        const { token } = useAuthStore.getState();
        
        // Optimistic update
        set({
          items: get().items.map((i) => (i.id === id ? { ...i, quantity } : i)),
        });

        if (token) {
          try {
            await api.put(`/user/cart/${id}`, { quantity });
            get().fetchCart(); // Sync final prices/data from server
          } catch (e) {
            console.error('Failed to update quantity', e);
          }
        }
      },

      clearCart: () => set({ items: [] }),
      
      total: () => get().items.reduce((acc, item) => acc + item.price * item.quantity, 0),
    }),
    { name: 'cart-storage' }
  )
);
