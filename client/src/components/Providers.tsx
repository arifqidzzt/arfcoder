'use client';

import { GoogleOAuthProvider } from "@react-oauth/google";
import { Toaster } from "react-hot-toast";
import ChatWidget from "@/components/ChatWidget";
import { useEffect } from "react";
import "aos/dist/aos.css";
import { useAuthStore } from "@/store/useAuthStore";

const AOSInit = () => {
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const AOS = require('aos');
      AOS.init({ duration: 800, once: true, easing: 'ease-out-cubic' });
    }
  }, []);
  return null;
};

export default function Providers({ children }: { children: React.ReactNode }) {
  const checkAuth = useAuthStore((state) => state.checkAuth);

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  return (
    <GoogleOAuthProvider clientId={process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || ''}>
      <AOSInit />
      <Toaster 
        position="bottom-right" 
        reverseOrder={false}
        gutter={8}
        toastOptions={{
          duration: 4000,
          className: 'text-sm font-medium border border-gray-100 shadow-xl rounded-2xl',
          style: {
            background: '#fff',
            color: '#000',
          },
        }}
        containerStyle={{
          bottom: 40,
          right: 40,
        }}
      />
      {children}
      <ChatWidget />
    </GoogleOAuthProvider>
  );
}