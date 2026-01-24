'use client';

import { GoogleOAuthProvider } from "@react-oauth/google";
import { Toaster } from "react-hot-toast";
import ChatWidget from "@/components/ChatWidget";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { useEffect } from "react";

// Helper component to init AOS
const AOSInit = () => {
  useEffect(() => {
    // Only run on client side
    if (typeof window !== 'undefined') {
      import('aos').then((AOS) => {
        // @ts-ignore
        import('aos/dist/aos.css'); // Import CSS dynamically
        AOS.init({
          duration: 800,
          once: true,
          easing: 'ease-out-cubic',
        });
      }).catch(e => console.log("AOS init error", e));
    }
  }, []);
  return null;
};

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased selection:bg-black selection:text-white`}>
        <GoogleOAuthProvider clientId={process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || ''}>
          <AOSInit />
          <Toaster position="bottom-right" />
          {children}
          <ChatWidget />
        </GoogleOAuthProvider>
      </body>
    </html>
  );
}