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
    footer: {
      desc: "Solusi terpercaya untuk kebutuhan digital dan pengembangan perangkat lunak Anda.",
      quick_links: "Tautan Cepat",
      support: "Dukungan",
      contact: "Hubungi Kami",
      rights: "Hak Cipta Dilindungi."
    },
    home: {
      hero_title: "Solusi Digital Terbaik Untuk Masa Depan Anda",
      hero_desc: "Kami menyediakan berbagai produk digital dan jasa profesional untuk membantu bisnis Anda tumbuh lebih cepat.",
      shop_now: "Belanja Sekarang",
      our_services: "Layanan Kami",
      featured_products: "Produk Unggulan",
      why_us: "Mengapa Memilih Kami?",
      secure_payment: "Pembayaran Aman",
      fast_delivery: "Proses Cepat",
      best_support: "Dukungan 24/7"
    },
    auth: {
      login_title: "Selamat Datang Kembali",
      login_desc: "Masuk untuk melanjutkan belanja",
      register_title: "Buat Akun Baru",
      register_desc: "Daftar sekarang dan nikmati layanan kami",
      forgot_title: "Lupa Kata Sandi?",
      forgot_desc: "Masukkan email untuk mereset kata sandi",
      email: "Alamat Email",
      password: "Kata Sandi",
      confirm_password: "Konfirmasi Sandi",
      name: "Nama Lengkap",
      btn_login: "Masuk Sekarang",
      btn_register: "Daftar Sekarang",
      btn_send: "Kirim Tautan Reset",
      no_account: "Belum punya akun?",
      have_account: "Sudah punya akun?",
      login_link: "Masuk di sini",
      register_link: "Daftar di sini"
    },
    products: {
      title: "Katalog Produk",
      search: "Cari produk digital...",
      empty: "Produk tidak ditemukan",
      buy: "Beli Sekarang",
      add_to_cart: "Tambah ke Keranjang",
      stock: "Stok",
      description: "Deskripsi Produk",
      related: "Produk Terkait",
      back: "Kembali",
      items_found: "Produk ditemukan"
    },
    services: {
      title: "Layanan Jasa",
      desc: "Solusi profesional untuk kebutuhan pengembangan Anda",
      order_service: "Pesan Jasa",
      contact_admin: "Hubungi Admin",
    },
    cart: {
      title: "Keranjang Belanja",
      empty: "Keranjang Belanja Kosong",
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
      items: "Barang",
      voucher: "Punya Kode Promo?",
      apply: "Pasang",
      remove: "Hapus",
      create_order: "Buat Pesanan",
      select_payment: "Pilih Metode Pembayaran",
      only_mobile: "Hanya di HP",
    },
    orders: {
      list_title: "Pesanan Saya",
      id: "ID Pesanan",
      date: "Tanggal",
      title: "Rincian Pesanan",
      status: "Status Pesanan",
      limit: "Batas Pembayaran",
      instruction: "Instruksi Pembayaran",
      copy: "Salin",
      scan_qr: "Scan QR untuk membayar",
      open_app: "Buka Aplikasi",
      cancel_order: "Batalkan Pesanan",
      items: "Barang yang Dibeli",
      success_title: "Pembayaran Berhasil!",
      success_desc: "Terima kasih. Pesanan akan segera diproses.",
      redirecting: "Mengalihkan dalam",
      empty: "Belum ada pesanan",
    },
    profile: {
      title: "Profil Saya",
      edit: "Ubah Profil",
      security: "Keamanan & 2FA",
      save: "Simpan Perubahan",
      logout_all: "Keluar dari semua perangkat",
      change_pass: "Ganti Kata Sandi"
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
    footer: {
      desc: "Trusted solution for your digital needs and software development.",
      quick_links: "Quick Links",
      support: "Support",
      contact: "Contact Us",
      rights: "All Rights Reserved."
    },
    home: {
      hero_title: "Best Digital Solutions For Your Future",
      hero_desc: "We provide various digital products and professional services to help your business grow faster.",
      shop_now: "Shop Now",
      our_services: "Our Services",
      featured_products: "Featured Products",
      why_us: "Why Choose Us?",
      secure_payment: "Secure Payment",
      fast_delivery: "Fast Process",
      best_support: "24/7 Support"
    },
    auth: {
      login_title: "Welcome Back",
      login_desc: "Sign in to continue shopping",
      register_title: "Create New Account",
      register_desc: "Register now and enjoy our services",
      forgot_title: "Forgot Password?",
      forgot_desc: "Enter your email to reset your password",
      email: "Email Address",
      password: "Password",
      confirm_password: "Confirm Password",
      name: "Full Name",
      btn_login: "Login Now",
      btn_register: "Register Now",
      btn_send: "Send Reset Link",
      no_account: "Don't have an account?",
      have_account: "Already have an account?",
      login_link: "Login here",
      register_link: "Register here"
    },
    products: {
      title: "Product Catalog",
      search: "Search digital products...",
      empty: "Products not found",
      buy: "Buy Now",
      add_to_cart: "Add to Cart",
      stock: "Stock",
      description: "Product Description",
      related: "Related Products",
      back: "Back",
      items_found: "Products found"
    },
    services: {
      title: "Our Services",
      desc: "Professional solutions for your development needs",
      order_service: "Order Service",
      contact_admin: "Contact Admin",
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
      items: "Items",
      voucher: "Have a Promo Code?",
      apply: "Apply",
      remove: "Remove",
      create_order: "Create Order",
      select_payment: "Select Payment Method",
      only_mobile: "Mobile Only",
    },
    orders: {
      list_title: "My Orders",
      id: "Order ID",
      date: "Date",
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
      redirecting: "Redirecting in",
      empty: "No orders yet",
    },
    profile: {
      title: "My Profile",
      edit: "Edit Profile",
      security: "Security & 2FA",
      save: "Save Changes",
      logout_all: "Logout from all devices",
      change_pass: "Change Password"
    }
  },
};

export const useTranslation = () => {
  const language = useSettingsStore((state) => state.language);
  
  const t = (path: string) => {
    const keys = path.split(".");
    let result: any = translations[language];
    
    for (const key of keys) {
      if (!result || result[key] === undefined) return path;
      result = result[key];
    }
    
    return result;
  };

  return { t, language, setLanguage: useSettingsStore((state) => state.setLanguage) };
};