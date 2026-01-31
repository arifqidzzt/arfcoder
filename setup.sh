#!/bin/bash

# ==========================================
# ARFCODER ULTIMATE INSTALLER (VPS) - V3.0
# ==========================================

if [ "$EUID" -ne 0 ]; then
  echo "❌ Mohon jalankan script ini sebagai root (sudo ./setup.sh)"
  exit
fi

echo "=================================================="
echo "   🚀  ARFCODER AUTO INSTALLER & SETUP  🚀"
echo "=================================================="
echo ""

# --- 1. GATHER INFO ---
read -p "1. Masukkan Domain/IP VPS: " DOMAIN
read -p "2. Nama Database Baru: " DB_NAME
read -p "3. Password Database Baru: " DB_PASSWORD
read -p "4. JWT Secret: " JWT_SECRET
read -p "5. Refresh Token Secret: " REFRESH_TOKEN_SECRET
read -p "6. APP SECRET KEY (Min 32 karakter): " APP_SECRET_KEY

echo ""
echo "--- KONFIGURASI PAYMENT & EMAIL ---"
read -p "7. Midtrans SERVER Key: " MIDTRANS_SERVER_KEY
read -p "8. Midtrans CLIENT Key: " MIDTRANS_CLIENT_KEY
read -p "9. Midtrans Production Mode? (y/n, default n): " MT_PROD_INPUT
if [[ "$MT_PROD_INPUT" == "y" || "$MT_PROD_INPUT" == "Y" ]]; then
    MIDTRANS_IS_PRODUCTION="true"
else
    MIDTRANS_IS_PRODUCTION="false"
fi
read -p "10. Resend API Key: " RESEND_API_KEY
read -p "11. Email Sender Name: " EMAIL_FROM
read -p "12. Google Client ID: " GOOGLE_CLIENT_ID

echo ""
echo "⏳ Memproses..."
ENCODED_DB_PASSWORD=$(python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus('$DB_PASSWORD'))")

# --- ADD SWAP (For Low RAM VPS) ---
# Cek apakah swapfile sudah ada, jika belum buat 4GB
if [ ! -f /swapfile ]; then
    echo "💾 Creating 4GB Swap file (Agar tidak stuck saat build)..."
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    # Buat permanen di fstab
    if ! grep -q "/swapfile" /etc/fstab; then
        echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    fi
    echo "✅ Swap 4GB berhasil dibuat."
else
    echo "ℹ️ Swap file sudah ada. Skip."
fi

# --- 2. INSTALL DEPENDENCIES ---
apt update && apt upgrade -y
apt install -y curl git nginx postgresql postgresql-contrib build-essential ufw python3 unzip certbot python3-certbot-nginx speedtest-cli

# Install Node.js
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi
npm install -g pm2 typescript ts-node

# Install Rclone (Backup)
if ! command -v rclone &> /dev/null; then
    curl https://rclone.org/install.sh | bash
fi

# --- 3. DATABASE SETUP ---
sudo -u postgres psql -c "CREATE USER arfcoder_user WITH PASSWORD '$DB_PASSWORD';" || true
sudo -u postgres psql -c "ALTER USER arfcoder_user WITH SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER arfcoder_user;" || true

DATABASE_URL="postgresql://arfcoder_user:$ENCODED_DB_PASSWORD@localhost:5432/$DB_NAME?search_path=public"

# --- 4. RESTORE BACKUP OPTION ---
echo ""
read -p "❓ Apakah Anda punya file backup (.sql) yang ingin di-restore? (y/n): " DO_RESTORE
if [ "$DO_RESTORE" == "y" ]; then
    read -p "📂 Masukkan path file backup (contoh: /root/backup.sql): " BACKUP_PATH
    if [ -f "$BACKUP_PATH" ]; then
        echo "🔄 Merestore database..."
        PGPASSWORD=$DB_PASSWORD psql -U arfcoder_user -h localhost -d $DB_NAME < $BACKUP_PATH
        echo "✅ Restore berhasil!"
    else
        echo "❌ File tidak ditemukan. Lewati restore."
    fi
fi

# --- 5. PROJECT SETUP ---
PROJECT_DIR=$(pwd)

# Setup Backend
cd $PROJECT_DIR/server
cat > .env <<EOL
DATABASE_URL="$DATABASE_URL"
PORT=5000
JWT_SECRET="$JWT_SECRET"
REFRESH_TOKEN_SECRET="$REFRESH_TOKEN_SECRET"
APP_SECRET_KEY="$APP_SECRET_KEY"
CLIENT_URL="https://$DOMAIN"
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
if [ "$DO_RESTORE" != "y" ]; then
    npx prisma migrate deploy
fi
npm run build
pm2 delete arfcoder-server 2>/dev/null || true
pm2 start dist/index.js --name arfcoder-server

# Setup Frontend
cd $PROJECT_DIR/client
cat > .env.local <<EOL
NEXT_PUBLIC_API_URL="https://$DOMAIN/api"
NEXT_PUBLIC_SOCKET_URL="https://$DOMAIN"
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

# --- 6. NGINX & SSL ---
NGINX_CONF="/etc/nginx/sites-available/arfcoder"
cat > $NGINX_CONF <<EOL
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
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

# Auto SSL
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN --redirect || echo "⚠️ SSL Gagal. Cek DNS atau jalankan certbot manual nanti."

# --- 7. CREATE ADMIN & BACKUP HELPER ---
cd $PROJECT_DIR/server
cat > create-admin-script.js <<EOL
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();
const readline = require('readline').createInterface({ input: process.stdin, output: process.stdout });

readline.question('Email Admin: ', email => {
  readline.question('Password Admin: ', async password => {
    const hashedPassword = await bcrypt.hash(password, 10);
    try {
      await prisma.user.upsert({
        where: { email: email },
        update: { role: 'SUPER_ADMIN', password: hashedPassword },
        create: { email, name: 'Super Admin', password: hashedPassword, role: 'SUPER_ADMIN', isVerified: true },
      });
      console.log('✅ Admin Created!');
    } catch(e) { console.error(e); }
    finally { await prisma.\$disconnect(); readline.close(); }
  });
});
EOL

# Create Backup Script
cd $PROJECT_DIR
cat > backup.sh <<EOL
#!/bin/bash
# Auto Backup by Setup Script
DB_NAME="$DB_NAME"
DB_USER="arfcoder_user"
REMOTE_NAME="gdrive"
REMOTE_FOLDER="arfcoder_backups"
BACKUP_DIR="/root/db_backups"
TIMESTAMP=\$(date +%F-%H%M)

mkdir -p \$BACKUP_DIR
export PGPASSWORD='$DB_PASSWORD'

echo "📦 Backup starting..."
pg_dump -U \$DB_USER -h localhost \$DB_NAME > \$BACKUP_DIR/backup-\$TIMESTAMP.sql

if command -v rclone &> /dev/null; then
    rclone copy \$BACKUP_DIR/backup-\$TIMESTAMP.sql \$REMOTE_NAME:\$REMOTE_FOLDER
    echo "✅ Uploaded to Drive."
else
    echo "❌ Rclone not configured."
fi

find \$BACKUP_DIR -type f -mtime +3 -name "*.sql" -delete
EOL
chmod +x backup.sh

# Setup Cron Job (Auto Backup 2 AM)
CRON_CMD="0 2 * * * /bin/bash $PROJECT_DIR/backup.sh >> /var/log/backup.log 2>&1"
# Remove old entry if exists to avoid duplicates, then add new
(crontab -l 2>/dev/null | grep -v "backup.sh"; echo "$CRON_CMD") | crontab -
echo "✅ Cronjob for backup configured (Daily 2 AM)."

echo ""
echo "=================================================="
echo "✅  INSTALASI SELESAI!"
echo "=================================================="
echo "1. Buat Admin: cd server && node create-admin-script.js"
echo "2. Aktifkan Backup: Ketik 'rclone config' -> New -> gdrive -> Google Drive"
echo "   (Backup otomatis jam 2 pagi sudah dijadwalkan!)"
echo "=================================================="
