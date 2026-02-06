import { useSettingsStore } from "@/store/useSettingsStore";

const translations = {
  id: {
    navbar: {
      home: "Beranda",
      products: "Produk",
      services: "Jasa",
      orders: "Pesanan",
      admin: "Admin",
      logout: "Keluar",
      login: "Masuk",
      menu: "Menu Navigasi",
      language: "Bahasa"
    },
    cart: {
      title: "Keranjang",
      empty: "Keranjang Kosong",
      start_shopping: "Mulai Belanja",
      summary: "Ringkasan",
      subtotal: "Subtotal",
      total: "Total",
      checkout: "Checkout Sekarang",
      remove_confirm: "Hapus item ini?",
      cancel: "Batal",
      delete: "Hapus"
    },
    checkout: {
      title: "Konfirmasi Pesanan",
      address: "Alamat & Catatan",
      summary: "Ringkasan",
      voucher: "Punya Kode Promo?",
      apply: "Pasang",
      remove: "Hapus",
      create_order: "Buat Pesanan",
      select_payment: "Pilih Metode Pembayaran",
      only_mobile: "Hanya tersedia di HP",
    },
    orders: {
      title: "Rincian Pesanan",
      status: "Status Pesanan",
      limit: "Batas",
      instruction: "Instruksi Pembayaran",
      copy: "Salin",
      scan_qr: "Scan QR untuk membayar",
      open_app: "Buka Aplikasi",
      cancel_order: "Batalkan Pesanan",
      items: "Barang yang Dibeli",
      success_title: "Pembayaran Berhasil!",
      success_desc: "Terima kasih. Pesanan akan segera diproses.",
      redirecting: "Mengalihkan dalam"
    }
  },
  en: {
    navbar: {
      home: "Home",
      products: "Products",
      services: "Services",
      orders: "Orders",
      admin: "Admin",
      logout: "Logout",
      login: "Login",
      menu: "Navigation Menu",
      language: "Language"
    },
    cart: {
      title: "Shopping Cart",
      empty: "Your Cart is Empty",
      start_shopping: "Start Shopping",
      summary: "Summary",
      subtotal: "Subtotal",
      total: "Total",
      checkout: "Checkout Now",
      remove_confirm: "Remove this item?",
      cancel: "Cancel",
      delete: "Delete"
    },
    checkout: {
      title: "Order Confirmation",
      address: "Address & Notes",
      summary: "Summary",
      voucher: "Have a Promo Code?",
      apply: "Apply",
      remove: "Remove",
      create_order: "Create Order",
      select_payment: "Select Payment Method",
      only_mobile: "Only available on Mobile",
    },
    orders: {
      title: "Order Details",
      status: "Order Status",
      limit: "Deadline",
      instruction: "Payment Instructions",
      copy: "Copy",
      scan_qr: "Scan QR to pay",
      open_app: "Open App",
      cancel_order: "Cancel Order",
      items: "Purchased Items",
      success_title: "Payment Successful!",
      success_desc: "Thank you. Your order will be processed shortly.",
      redirecting: "Redirecting in"
    }
  },
};

export const useTranslation = () => {
  const language = useSettingsStore((state) => state.language);
  
  const t = (path: string) => {
    const keys = path.split(".");
    let result: any = translations[language];
    
    for (const key of keys) {
      if (result[key] === undefined) return path;
      result = result[key];
    }
    
    return result;
  };

  return { t, language, setLanguage: useSettingsStore((state) => state.setLanguage) };
};