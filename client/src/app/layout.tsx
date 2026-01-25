import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Providers from "@/components/Providers";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "ArfCoder | Digital Services & Product Store",
  description: "Modern Minimalist E-commerce for Digital Services and Products",
  icons: {
    icon: '/app_ico.ico', // Pastikan file ini ada di folder public
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased selection:bg-black selection:text-white`}>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
}
