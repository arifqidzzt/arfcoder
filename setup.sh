#!/bin/bash

# ==========================================
# ARFCODER ULTIMATE INSTALLER (VPS) - V2 FINAL
# ==========================================
# Script ini dirancang untuk "One-Click Deploy"
# ==========================================

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Mohon jalankan script ini sebagai root (sudo ./setup.sh)"
  exit
fi

echo "=================================================="
echo "   🚀  ARFCODER AUTO INSTALLER & SETUP  🚀"
echo "=================================================="
echo "Pastikan Anda sudah menyiapkan semua API KEY."
echo ""

# --- 1. GATHER ALL INFORMATION ---
echo "--- KONFIGURASI BASIC ---"
read -p "1. Masukkan Domain/IP VPS (misal: toko.com atau 103.xx.xx.xx): " DOMAIN
read -p "2. Nama Database Baru (misal: arfcoder_db): " DB_NAME
read -p "3. Password Database Baru: " DB_PASSWORD
read -p "4. JWT Secret (ketik acak, misal: x7s8d6f876): " JWT_SECRET
read -p "5. Refresh Token Secret (ketik acak beda, misal: h3h3h3): " REFRESH_TOKEN_SECRET

echo ""
echo "--- KONFIGURASI PAYMENT (MIDTRANS) ---"
read -p "6. Midtrans SERVER Key: " MIDTRANS_SERVER_KEY
read -p "7. Midtrans CLIENT Key: " MIDTRANS_CLIENT_KEY
read -p "8. Apakah ini Production/Live? (y/n, jika n = Sandbox): " IS_PROD
if [ "$IS_PROD" == "y" ]; then
    MIDTRANS_IS_PRODUCTION="true"
else
    MIDTRANS_IS_PRODUCTION="false"
fi

echo ""
echo "--- KONFIGURASI EMAIL & GOOGLE ---"
read -p "9. Resend API Key (re_123... untuk kirim email): " RESEND_API_KEY
read -p "10. Email Sender (misal: 'Admin <noreply@toko.com>'): " EMAIL_FROM
if [ -z "$EMAIL_FROM" ]; then
    EMAIL_FROM="onboarding@resend.dev"
fi
read -p "11. Google Client ID (apps.googleusercontent.com): " GOOGLE_CLIENT_ID
read -p "12. APP SECRET KEY (Kunci Enkripsi Payload, minimal 32 karakter acak): " APP_SECRET_KEY

echo ""
echo "⏳ Memulai proses instalasi..."
echo "Sambil menunggu, Anda bisa ngopi dulu ☕ (Estimasi: 5-10 menit)"
sleep 3

# --- 2. SYSTEM UPDATE & FIREWALL ---
echo ""
echo "📦 Update Sistem & Firewall..."
apt update && apt upgrade -y
apt install -y curl git nginx postgresql postgresql-contrib build-essential ufw

# Setup Firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
# ufw enable # Opsional

# Install Node.js 20.x
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

# Install PM2 Global
npm install -g pm2 typescript ts-node

# --- 3. DATABASE SETUP ---
echo ""
echo "🗄️  Setup Database PostgreSQL..."
sudo -u postgres psql -c "CREATE USER arfcoder_user WITH PASSWORD '$DB_PASSWORD';" || true
sudo -u postgres psql -c "ALTER USER arfcoder_user WITH SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER arfcoder_user;" || true

DATABASE_URL="postgresql://arfcoder_user:$DB_PASSWORD@localhost:5432/$DB_NAME?schema=public"

# --- 4. PROJECT SETUP ---
PROJECT_DIR=$(pwd)
echo "📂 Project Directory: $PROJECT_DIR"

# --- 5. BACKEND SETUP (SERVER) ---
echo ""
echo "⚙️  Setup Backend..."
cd $PROJECT_DIR/server

# Tulis .env Server LENGKAP
cat > .env <<EOL
DATABASE_URL="$DATABASE_URL"
PORT=5000
JWT_SECRET="$JWT_SECRET"
REFRESH_TOKEN_SECRET="$REFRESH_TOKEN_SECRET"
APP_SECRET_KEY="$APP_SECRET_KEY"
CLIENT_URL="http://$DOMAIN"

# Midtrans
MIDTRANS_SERVER_KEY="$MIDTRANS_SERVER_KEY"
MIDTRANS_CLIENT_KEY="$MIDTRANS_CLIENT_KEY"
MIDTRANS_IS_PRODUCTION="$MIDTRANS_IS_PRODUCTION"

# Email & Auth
RESEND_API_KEY="$RESEND_API_KEY"
EMAIL_FROM="$EMAIL_FROM"
GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"

# WhatsApp
WA_SESSION_PATH="./wa_sessions"
EOL

# Install & Build
npm install
npx prisma generate
npx prisma migrate deploy
npm run build

# PM2 Restart/Start
pm2 delete arfcoder-server 2>/dev/null || true
pm2 start dist/index.js --name arfcoder-server

# --- 6. FRONTEND SETUP (CLIENT) ---
echo ""
echo "🎨 Setup Frontend..."
cd $PROJECT_DIR/client

# Tulis .env.local Client LENGKAP
cat > .env.local <<EOL
NEXT_PUBLIC_API_URL="http://$DOMAIN/api"
NEXT_PUBLIC_SOCKET_URL="http://$DOMAIN"
NEXT_PUBLIC_MIDTRANS_CLIENT_KEY="$MIDTRANS_CLIENT_KEY"
NEXT_PUBLIC_GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
NEXT_PUBLIC_APP_SECRET_KEY="$APP_SECRET_KEY"
EOL

# Install & Build
npm install
npm run build

# PM2 Restart/Start
pm2 delete arfcoder-client 2>/dev/null || true
pm2 start npm --name arfcoder-client -- start

# Save PM2 State
pm2 save
pm2 startup | bash

# --- 7. NGINX CONFIGURATION ---
echo ""
echo "🌐 Setup Nginx Reverse Proxy..."
NGINX_CONF="/etc/nginx/sites-available/arfcoder"

cat > $NGINX_CONF <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /socket.io/ {
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header Host \$host;
      proxy_pass http://localhost:5000;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection "upgrade";
    }
}
EOL

# Activate Site
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# --- 8. FINAL REPORT ---
echo ""
echo "=================================================="
echo "✅  INSTALASI SELESAI TOTAL!  ✅"
echo "=================================================="
echo "Website Akses  : http://$DOMAIN"
echo "API Keys       : Terpasang Lengkap (Email, Payment, Auth)"
echo ""
echo "Gunakan: pm2 monit (untuk cek status server)"
echo "=================================================="
