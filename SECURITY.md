# 🛡️ SECURITY POLICY & ARCHITECTURE REFERENCE

Dokumen ini berfungsi sebagai referensi teknis lengkap ("Resep Super") untuk arsitektur, keamanan, dan teknologi yang digunakan dalam proyek **ARFCODER**. Dokumen ini ditujukan untuk pengembang, auditor keamanan, dan tim DevOps.

---

## 🏗️ 1. Arsitektur Frontend (Client)

Aplikasi klien dibangun menggunakan teknologi modern berbasis React dengan fokus pada performa, keamanan tipe data, dan antarmuka responsif.

### 🛠️ Core Technology Stack
*   **Framework:** [Next.js 16.1.4](https://nextjs.org/) (App Router) - Framework React full-stack terbaru.
*   **Bahasa:** [TypeScript](https://www.typescriptlang.org/) (Strict Mode) - Menjamin keamanan tipe data statis.
*   **Runtime:** Node.js v20.x (LTS).
*   **Styling:**
    *   **Tailwind CSS v4:** Framework CSS utility-first untuk styling cepat dan konsisten.
    *   **PostCSS:** Tooling untuk transformasi CSS.
    *   **Framer Motion:** Animasi UI yang halus dan kompleks.

### 🧩 State Management & Logic
*   **Zustand:** Digunakan untuk manajemen state global yang ringan (keranjang belanja, status auth).
    *   File: `src/store/useAuthStore.ts`, `src/store/useCartStore.ts`.
*   **Axios:** Klien HTTP untuk komunikasi dengan Backend API.
*   **Socket.io-client:** Untuk fitur Real-time Chat.

### 🔒 Frontend Security Features
*   **AuthGuard:** Komponen HOC (`src/components/AuthGuard.tsx`) yang memproteksi rute privat. Melakukan pengecekan token JWT dan redirect otomatis jika sesi habis.
*   **JWT Decode:** Library `jwt-decode` digunakan di sisi klien untuk membaca payload token tanpa verifikasi signature (verifikasi tetap di backend).
*   **Crypto-js:** Enkripsi data sensitif di sisi klien sebelum dikirim (jika diperlukan).
*   **Environment Variables:** Menggunakan `.env.local` dengan prefix `NEXT_PUBLIC_` untuk konfigurasi aman.

### 📦 Key Libraries
*   `lucide-react`: Ikon SVG yang ringan.
*   `react-hot-toast`: Notifikasi toast yang user-friendly.
*   `chart.js` & `react-chartjs-2`: Visualisasi data statistik di dashboard admin.
*   `@react-oauth/google`: Integrasi Login Google OAuth.

---

## ⚙️ 2. Arsitektur Backend (Server)

Server dibangun sebagai RESTful API yang terpisah (Decoupled Architecture) dengan fokus pada skalabilitas dan keamanan data.

### 🛠️ Core Technology Stack
*   **Runtime:** Node.js & Express.js v5.
*   **Bahasa:** TypeScript.
*   **Database:** PostgreSQL (Relational Database).
*   **ORM:** Prisma Client (Type-safe database query).

### 🔐 Security & Middleware System
Sistem keamanan backend menerapkan standar industri untuk mencegah serangan umum:
1.  **Helmet (`helmet`):** Mengamankan HTTP headers (X-DNS-Prefetch-Control, X-Frame-Options, dll) untuk mencegah serangan XSS dan Clickjacking.
2.  **CORS (`cors`):** Mengatur kebijakan Cross-Origin Resource Sharing agar API hanya bisa diakses oleh domain frontend yang diizinkan.
3.  **Rate Limiting (`express-rate-limit`):** Membatasi jumlah request dari satu IP dalam kurun waktu tertentu untuk mencegah serangan DDoS atau Brute Force.
4.  **Input Validation (`zod`):** Validasi skema data yang ketat untuk setiap request body yang masuk, mencegah SQL Injection dan data korup.
5.  **Bcrypt (`bcryptjs`):** Hashing password satu arah dengan salt. Password asli tidak pernah disimpan di database.
6.  **JWT Auth:** Menggunakan `jsonwebtoken` dengan mekanisme **Access Token** (jangka pendek) dan **Refresh Token** (jangka panjang/rotation).

### 🔌 Integrasi Layanan Pihak Ketiga (API)
*   **Midtrans:** Payment Gateway untuk pembayaran otomatis (QRIS, VA, E-Wallet).
    *   Mode: Production/Sandbox toggleable.
    *   Library: `midtrans-client`.
*   **Resend:** Layanan pengiriman email transaksional (OTP, Notifikasi).
*   **Google Auth:** Verifikasi token OAuth dari login Google.
*   **WhatsApp Web:** Menggunakan `@whiskeysockets/baileys` untuk integrasi bot WhatsApp (Notifikasi Order/OTP).

### 📡 Real-time Communication
*   **Socket.io:** Server websocket untuk fitur Live Chat antara User dan Admin.

---

## 🗄️ 3. Database Schema (PostgreSQL)

Struktur database dirancang menggunakan Prisma Schema (`schema.prisma`).

### Tabel Utama:
*   **User:** Menyimpan data pengguna, role (`USER`, `ADMIN`, `SUPER_ADMIN`), dan kredensial (hashed password/Google ID).
*   **Product:** Katalog produk/jasa dengan relasi ke kategori.
*   **Order:** Transaksi pembelian dengan status (`PENDING`, `PAID`, `SHIPPED`, dll) dan data pembayaran (Snap Token).
*   **CartItem:** Keranjang belanja persisten per user.
*   **Message:** Riwayat chat untuk fitur live support.
*   **Otp:** Token verifikasi email sementara.

---

## ☁️ 4. Infrastruktur & DevOps (VPS)

Sistem berjalan di atas Virtual Private Server (VPS) Linux Ubuntu dengan konfigurasi high-availability.

### 🚀 Deployment Stack
*   **Web Server:** Nginx (sebagai Reverse Proxy & Load Balancer).
    *   Menangani SSL Termination (HTTPS).
    *   Meneruskan traffic `/api` ke port 5000 (Backend).
    *   Meneruskan traffic `/` ke port 3000 (Frontend).
*   **Process Manager:** PM2 (Process Manager 2).
    *   Menjaga aplikasi tetap hidup (Auto-restart on crash).
    *   Manajemen log (`pm2 logs`).
    *   Startup script (`pm2 startup`).
*   **SSL/TLS:** Let's Encrypt (Certbot). Sertifikat SSL otomatis diperbarui.

### 💾 Backup & Data Safety
*   **Automated Backup:** Script Bash (`backup.sh`) yang berjalan via Cron Job setiap jam 02:00 WIB.
*   **Offsite Storage:** Backup database dikirim otomatis ke **Google Drive** menggunakan **Rclone**.
*   **Retention Policy:** Backup lokal dihapus otomatis setelah 3 hari untuk menghemat ruang disk VPS.
*   **Swap Memory:** Alokasi 4GB Swap File untuk mencegah *Out of Memory (OOM)* pada VPS dengan RAM terbatas.

### 🛡️ Firewall (UFW)
Hanya port esensial yang dibuka:
*   `22` (SSH - Sebaiknya diganti ke port non-standar).
*   `80` (HTTP - Redirect ke HTTPS).
*   `443` (HTTPS - Traffic utama).

---

## 🚀 5. API Reference & Documentation

API ARFCODER mengikuti arsitektur **RESTful** dengan format pertukaran data JSON. 

### 🔐 Authentication & Authorization
*   **Method:** Bearer Token via Header `Authorization`.
*   **Access Token:** Masa berlaku singkat, digunakan untuk setiap request ke rute terproteksi.
*   **Role Based Access Control (RBAC):** Backend memverifikasi role pengguna (`USER`, `ADMIN`, `SUPER_ADMIN`) sebelum mengizinkan akses ke resource sensitif.

### 🛡️ API Security Headers & Protection
Setiap request ke API diproteksi oleh:
*   `X-App-Secret`: Custom header untuk memastikan request hanya datang dari aplikasi resmi kita (via `secureMiddleware`).
*   `Rate Limiting`: 
    *   Global: Max 500 req / 15 menit.
    *   Auth: Max 60 req / jam (Mencegah brute force).
*   `Helmet`: Menyembunyikan `X-Powered-By` (Node.js) dan mencegah MIME sniffing.

### 📍 Key Endpoints Map

#### 🔑 Auth Service (`/api/auth`)
| Endpoint | Method | Desc |
| :--- | :--- | :--- |
| `/register` | POST | Pendaftaran user baru & kirim OTP email. |
| `/login` | POST | Login & generate JWT Token. |
| `/verify-otp` | POST | Verifikasi kode OTP dari email. |
| `/google` | POST | Login/Register via Google OAuth. |
| `/forgot-password` | POST | Request link reset password. |

#### 📦 Product Service (`/api/products`)
| Endpoint | Method | Desc |
| :--- | :--- | :--- |
| `/` | GET | List semua produk (Public). |
| `/:id` | GET | Detail produk (Public). |
| `/services` | GET | List layanan jasa (Public). |

#### 🛒 Order Service (`/api/orders`)
| Endpoint | Method | Auth | Desc |
| :--- | :--- | :--- | :--- |
| `/` | POST | Yes | Buat pesanan baru & ambil Snap Token. |
| `/my` | GET | Yes | List riwayat pesanan milik user. |
| `/:id/pay` | POST | Yes | Regenerate token pembayaran jika expired. |
| `/midtrans-webhook` | POST | No | Callback otomatis dari Midtrans (Public). |

#### 👑 Admin Service (`/api/admin`)
*(Wajib Role ADMIN/SUPER_ADMIN)*
| Endpoint | Method | Desc |
| :--- | :--- | :--- |
| `/stats` | GET | Ambil data total sales, users, dan profit. |
| `/orders` | GET | Management semua order masuk. |
| `/users` | GET | Management data pelanggan. |
| `/wa/status` | GET | Cek status bot WhatsApp (Connected/Disconnected). |

---

## 📝 Kontak & Maintenance

Jika ditemukan celah keamanan atau bug kritis, harap segera hubungi Administrator Utama.
*   **Project Lead:** Arifqi
*   **Version:** 3.0 (Major Refactor)

---
*Dokumen ini dibuat otomatis dan diperbarui pada 29 Januari 2026.*