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
      rights: "Hak Cipta Dilindungi.",
      company: "Perusahaan"
    },
    home: {
      hero_title_part1: "Solusi Digital untuk",
      hero_title_part2: "Pertumbuhan Bisnis",
      hero_desc: "Kami mengubah ide kompleks menjadi produk digital yang simpel, elegan, dan berdampak besar bagi bisnis Anda.",
      shop_now: "Belanja Produk",
      our_services: "Konsultasi Gratis",
      featured_products: "Produk Unggulan",
      why_us: "Mengapa Memilih Kami?",
      secure_payment: "Pembayaran Aman",
      fast_delivery: "Proses Cepat",
      best_support: "Dukungan 24/7",
      start_transform: "Mulai Transformasi Digital Anda",
      register_now: "Daftar Sekarang",
      contact_sales: "Hubungi Sales",
      latest_products: "Produk Terbaru",
      view_all: "Lihat Semua",
      help_title: "Apa yang Bisa Kami Bantu?",
      help_desc: "Dari konsep hingga peluncuran, kami menangani seluruh siklus pengembangan produk digital Anda."
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
      register_link: "Daftar di sini",
      verify_title: "Verifikasi Akun",
      verify_desc: "Masukkan kode OTP yang kami kirim ke email Anda",
      btn_verify: "Verifikasi Sekarang"
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
      items_found: "Produk ditemukan",
      type: "Tipe Produk",
      sort: "Urutkan",
      newest: "Terbaru",
      price_low: "Harga Terendah",
      price_high: "Harga Tertinggi",
      all: "Semua Produk",
      digital: "Produk Digital",
      service_type: "Jasa & Layanan"
    },
    services: {
      title: "Layanan Jasa",
      desc: "Solusi profesional untuk kebutuhan pengembangan Anda",
      order_service: "Pesan Jasa Sekarang",
      contact_admin: "Hubungi Admin",
      features: "Fitur Unggulan"
    },
    cart: {
      title: "Keranjang Belanja",
      empty: "Keranjang Belanja Kosong",
      start_shopping: "Mulai Belanja",
      summary: "Ringkasan",
      subtotal: "Subtotal",
      total: "Total",
      checkout: "Checkout Sekarang",
      remove_confirm: "Hapus item ini dari keranjang?",
      cancel: "Batal",
      delete: "Hapus",
      tax: "Pajak & Biaya",
      free: "Gratis",
      secure_desc: "Transaksi aman & terenkripsi."
    },
    checkout: {
      title: "Konfirmasi Pesanan",
      address: "Alamat & Catatan Jasa",
      summary: "Ringkasan",
      items: "Barang",
      voucher: "Punya Kode Promo?",
      apply: "Pasang",
      remove: "Hapus",
      create_order: "Buat Pesanan Sekarang",
      select_payment: "Pilih Metode Pembayaran",
      only_mobile: "Hanya tersedia di Smartphone",
      placeholder_address: "Contoh: Alamat pengiriman atau detail instruksi jasa koding..."
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
      scan_qr: "Scan QR Code untuk membayar",
      open_app: "Buka Aplikasi",
      cancel_order: "Batalkan Pesanan",
      items: "Barang yang Dibeli",
      success_title: "Pembayaran Berhasil!",
      success_desc: "Terima kasih. Pesanan Anda akan segera diproses.",
      redirecting: "Mengalihkan dalam",
      empty: "Anda belum memiliki pesanan",
      invoice: "Nomor Invoice",
      timeline: "Timeline Pengerjaan",
      delivery: "Informasi Pengiriman / Akses",
      refund: "Ajukan Pengembalian Dana (Refund)",
      refund_form: "Formulir Refund",
      reason: "Alasan Refund",
      account: "Rekening Tujuan",
      submit_refund: "Kirim Pengajuan"
    },
    profile: {
      title: "Profil Pengguna",
      edit: "Ubah Profil",
      security: "Keamanan & 2FA",
      save: "Simpan Perubahan",
      logout_all: "Keluar dari semua perangkat",
      change_pass: "Ganti Kata Sandi",
      phone: "Nomor Telepon",
      verified: "Terverifikasi",
      unverified: "Belum Verifikasi"
    },
    policy: {
      terms: "Syarat & Ketentuan",
      privacy: "Kebijakan Privasi",
      refund: "Kebijakan Refund",
      faq: "Pusat Bantuan (FAQ)"
    },
    admin: {
      dashboard: "Dashboard",
      users: "Pengguna",
      vouchers: "Voucher",
      payments: "Pembayaran",
      settings: "Pengaturan",
      view_site: "Lihat Website"
    },
    common: {
      loading: "Memuat data...",
      error: "Terjadi kesalahan",
      success: "Berhasil",
      back: "Kembali",
      close: "Tutup"
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
      rights: "All Rights Reserved.",
      company: "Company"
    },
    home: {
      hero_title_part1: "Digital Solutions for",
      hero_title_part2: "Business Growth",
      hero_desc: "We turn complex ideas into simple, elegant digital products that have a major impact on your business.",
      shop_now: "Shop Products",
      our_services: "Free Consultation",
      featured_products: "Featured Products",
      why_us: "Why Choose Us?",
      secure_payment: "Secure Payment",
      fast_delivery: "Fast Process",
      best_support: "24/7 Support",
      start_transform: "Start Your Digital Transformation",
      register_now: "Register Now",
      contact_sales: "Contact Sales",
      latest_products: "Latest Products",
      view_all: "View All",
      help_title: "How Can We Help You?",
      help_desc: "From concept to launch, we handle your entire digital product development cycle."
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
      register_link: "Register here",
      verify_title: "Verify Account",
      verify_desc: "Enter the OTP code we sent to your email",
      btn_verify: "Verify Now"
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
      items_found: "Products found",
      type: "Product Type",
      sort: "Sort By",
      newest: "Newest",
      price_low: "Lowest Price",
      price_high: "Highest Price",
      all: "All Products",
      digital: "Digital Items",
      service_type: "Services"
    },
    services: {
      title: "Our Services",
      desc: "Professional solutions for your development needs",
      order_service: "Order Service Now",
      contact_admin: "Contact Admin",
      features: "Key Features"
    },
    cart: {
      title: "Shopping Cart",
      empty: "Your Cart is Empty",
      start_shopping: "Start Shopping",
      summary: "Summary",
      subtotal: "Subtotal",
      total: "Total",
      checkout: "Checkout Now",
      remove_confirm: "Remove this item from cart?",
      cancel: "Cancel",
      delete: "Delete",
      tax: "Tax & Fees",
      free: "Free",
      secure_desc: "Secure & encrypted transactions."
    },
    checkout: {
      title: "Order Confirmation",
      address: "Address & Service Notes",
      summary: "Summary",
      items: "Items",
      voucher: "Have a Promo Code?",
      apply: "Apply",
      remove: "Remove",
      create_order: "Create Order Now",
      select_payment: "Select Payment Method",
      only_mobile: "Only available on Smartphone",
      placeholder_address: "Example: Shipping address or detailed coding service instructions..."
    },
    orders: {
      list_title: "My Orders",
      id: "Order ID",
      date: "Date",
      title: "Order Details",
      status: "Order Status",
      limit: "Payment Deadline",
      instruction: "Payment Instructions",
      copy: "Copy",
      scan_qr: "Scan QR Code to pay",
      open_app: "Open App",
      cancel_order: "Cancel Order",
      items: "Purchased Items",
      success_title: "Payment Successful!",
      success_desc: "Thank you. Your order will be processed shortly.",
      redirecting: "Redirecting in",
      empty: "You don't have any orders yet",
      invoice: "Invoice Number",
      timeline: "Work Timeline",
      delivery: "Delivery Info / Access",
      refund: "Request a Refund",
      refund_form: "Refund Form",
      reason: "Refund Reason",
      account: "Target Account",
      submit_refund: "Submit Request"
    },
    profile: {
      title: "User Profile",
      edit: "Edit Profile",
      security: "Security & 2FA",
      save: "Save Changes",
      logout_all: "Logout from all devices",
      change_pass: "Change Password",
      phone: "Phone Number",
      verified: "Verified",
      unverified: "Unverified"
    },
    policy: {
      terms: "Terms & Conditions",
      privacy: "Privacy Policy",
      refund: "Refund Policy",
      faq: "Help Center (FAQ)"
    },
    admin: {
      dashboard: "Dashboard",
      users: "Users",
      vouchers: "Vouchers",
      payments: "Payments",
      settings: "Settings",
      view_site: "View Website"
    },
    common: {
      loading: "Loading data...",
      error: "Something went wrong",
      success: "Success",
      back: "Back",
      close: "Close"
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
