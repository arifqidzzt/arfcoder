import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import api from '@/lib/api';

interface User {
  id: string;
  email: string;
  name: string;
  role: string;
  avatar?: string | null;
  phoneNumber?: string | null;
  waBotNumber?: string | null;
  twoFactorEnabled?: boolean;
}

interface AuthStore {
  user: User | null;
  token: string | null;
  hasHydrated: boolean;
  setHasHydrated: (state: boolean) => void;
  login: (user: User, token: string) => void;
  logout: () => void;
  checkAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      hasHydrated: false,
      setHasHydrated: (state) => set({ hasHydrated: state }),
      login: (user, token) => set({ user, token }),
      logout: () => set({ user: null, token: null }),
      checkAuth: async () => {
        const token = get().token;
        if (!token) return;
        try {
          // Fetch fresh user data (include avatar)
          const res = await api.get('/user/profile');
          // Update user state but keep token
          set({ user: res.data }); 
        } catch (error) {
          // If token invalid (401) or network error, verify via interceptor or force logout here
          console.error("Auth check failed:", error);
          get().logout(); 
        }
      }
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => localStorage),
      onRehydrateStorage: () => (state) => {
        state?.setHasHydrated(true);
      },
    }
  )
);