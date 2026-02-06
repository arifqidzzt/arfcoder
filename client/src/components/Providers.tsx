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
      <Toaster position="top-center" />
      {children}
      <ChatWidget />
    </GoogleOAuthProvider>
  );
}
