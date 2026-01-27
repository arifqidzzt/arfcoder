#!/bin/bash

# ==========================================
# ARFCODER ULTIMATE INSTALLER (VPS) - V2.1 SECURE
# ==========================================

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Mohon jalankan script ini sebagai root (sudo ./setup.sh)"
  exit
fi

echo "=================================================="
echo "   🚀  ARFCODER AUTO INSTALLER & SETUP  🚀"
echo "=================================================="
echo ""

# --- 1. GATHER ALL INFORMATION ---
echo "--- KONFIGURASI BASIC ---"
read -p "1. Masukkan Domain/IP VPS: " DOMAIN
read -p "2. Nama Database Baru: " DB_NAME
read -p "3. Password Database Baru: " DB_PASSWORD
read -p "4. JWT Secret: " JWT_SECRET
read -p "5. Refresh Token Secret: " REFRESH_TOKEN_SECRET

echo ""
echo "--- KONFIGURASI PAYMENT & EMAIL ---"
read -p "6. Midtrans SERVER Key: " MIDTRANS_SERVER_KEY
read -p "7. Midtrans CLIENT Key: " MIDTRANS_CLIENT_KEY
read -p "8. Apakah ini Production/Live? (y/n): " IS_PROD
if [ "$IS_PROD" == "y" ]; then MIDTRANS_IS_PRODUCTION="true"; else MIDTRANS_IS_PRODUCTION="false"; fi

read -p "9. Resend API Key: " RESEND_API_KEY
read -p "10. Email Sender Name: " EMAIL_FROM
read -p "11. Google Client ID: " GOOGLE_CLIENT_ID
read -p "12. APP SECRET KEY (Min 32 karakter): " APP_SECRET_KEY

echo ""
echo "⏳ Memproses password dan memulai instalasi..."

# --- AUTO URL ENCODE PASSWORD (Agar karakter @ # : dll tidak merusak DB_URL) ---
# Menggunakan python3 (bawaan Ubuntu) untuk encoding
ENCODED_DB_PASSWORD=$(python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus('$DB_PASSWORD'))")

# --- 2. SYSTEM UPDATE & DEPENDENCIES ---
apt update && apt upgrade -y
apt install -y curl git nginx postgresql postgresql-contrib build-essential ufw python3

# Install Node.js 20.x
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi
npm install -g pm2 typescript ts-node

# --- 3. DATABASE SETUP ---
sudo -u postgres psql -c "CREATE USER arfcoder_user WITH PASSWORD '$DB_PASSWORD';" || true
sudo -u postgres psql -c "ALTER USER arfcoder_user WITH SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER arfcoder_user;" || true

# Gunakan password yang sudah di-encode di URL
DATABASE_URL="postgresql://arfcoder_user:$ENCODED_DB_PASSWORD@localhost:5432/$DB_NAME?search_path=public"

# --- 4. PROJECT SETUP ---
PROJECT_DIR=$(pwd)

# --- 5. BACKEND SETUP ---
cd $PROJECT_DIR/server
cat > .env <<EOL
DATABASE_URL="$DATABASE_URL"
PORT=5000
JWT_SECRET="$JWT_SECRET"
REFRESH_TOKEN_SECRET="$REFRESH_TOKEN_SECRET"
APP_SECRET_KEY="$APP_SECRET_KEY"
CLIENT_URL="http://$DOMAIN"
MIDTRANS_SERVER_KEY="$MIDTRANS_SERVER_KEY"
MIDTRANS_CLIENT_KEY="$MIDTRANS_CLIENT_KEY"
MIDTRANS_IS_PRODUCTION="$MIDTRANS_IS_PRODUCTION"
RESEND_API_KEY="$RESEND_API_KEY"
EMAIL_FROM="$EMAIL_FROM"
GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
WA_SESSION_PATH="./wa_sessions"
EOL

npm install
npx prisma generate
npx prisma migrate deploy
npm run build
pm2 delete arfcoder-server 2>/dev/null || true
pm2 start dist/index.js --name arfcoder-server

# --- 6. FRONTEND SETUP ---
cd $PROJECT_DIR/client
cat > .env.local <<EOL
NEXT_PUBLIC_API_URL="http://$DOMAIN/api"
NEXT_PUBLIC_SOCKET_URL="http://$DOMAIN"
NEXT_PUBLIC_MIDTRANS_CLIENT_KEY="$MIDTRANS_CLIENT_KEY"
NEXT_PUBLIC_GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
NEXT_PUBLIC_APP_SECRET_KEY="$APP_SECRET_KEY"
EOL

npm install
npm run build
pm2 delete arfcoder-client 2>/dev/null || true
pm2 start npm --name arfcoder-client -- start
pm2 save
pm2 startup | bash

# --- 7. NGINX SETUP ---
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
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

echo "✅ SETUP SELESAI TOTAL!"
echo "Akses: http://$DOMAIN"