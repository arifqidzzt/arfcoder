'use client';

import { GoogleOAuthProvider } from "@react-oauth/google";
import { Toaster } from "react-hot-toast";
import ChatWidget from "@/components/ChatWidget";
import { useEffect } from "react";
import "aos/dist/aos.css";

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
  return (
    <GoogleOAuthProvider clientId={process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || ''}>
      <AOSInit />
      <Toaster position="bottom-right" />
      {children}
      <ChatWidget />
    </GoogleOAuthProvider>
  );
}
