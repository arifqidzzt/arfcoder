import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

type Language = 'id' | 'en';

interface SettingsStore {
  language: Language;
  setLanguage: (lang: Language) => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      language: 'id',
      setLanguage: (lang) => set({ language: lang }),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
);
