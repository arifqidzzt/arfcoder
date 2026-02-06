import { useSettingsStore } from "@/store/useSettingsStore";

const translations = {
  id: {
    navbar: {
      home: "Beranda",
      products: "Produk",
      services: "Jasa",
      orders: "Pesanan Saya",
      admin: "Admin Panel",
      logout: "Keluar",
      login: "Masuk",
    },
    cart: {
      title: "Keranjang Belanja",
      empty: "Keranjang Belanja Kosong",
      start_shopping: "Mulai Belanja",
      summary: "Ringkasan",
      subtotal: "Subtotal",
      total: "Total",
      checkout: "Checkout Sekarang",
    },
    checkout: {
      title: "Konfirmasi Pesanan",
      address: "Alamat Pengiriman / Catatan Jasa",
      summary: "Ringkasan",
      voucher: "Punya Kode Promo?",
      apply: "Pasang",
      remove: "Hapus",
      create_order: "Buat Pesanan",
      select_payment: "Pilih Metode Pembayaran",
    },
  },
  en: {
    navbar: {
      home: "Home",
      products: "Products",
      services: "Services",
      orders: "My Orders",
      admin: "Admin Panel",
      logout: "Logout",
      login: "Login",
    },
    cart: {
      title: "Shopping Cart",
      empty: "Your Cart is Empty",
      start_shopping: "Start Shopping",
      summary: "Summary",
      subtotal: "Subtotal",
      total: "Total",
      checkout: "Checkout Now",
    },
    checkout: {
      title: "Order Confirmation",
      address: "Shipping Address / Service Notes",
      summary: "Summary",
      voucher: "Have a Promo Code?",
      apply: "Apply",
      remove: "Remove",
      create_order: "Create Order",
      select_payment: "Select Payment Method",
    },
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
