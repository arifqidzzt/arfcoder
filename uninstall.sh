#!/bin/bash

# ==========================================
# ARFCODER FACTORY RESET / UNINSTALLER
# ==========================================
# PERINGATAN: SCRIPT INI AKAN MENGHAPUS SEMUA DATA PROJECT,
# DATABASE, DAN MENG-UNINSTALL SOFTWARE TERKAIT.
# ==========================================

if [ "$EUID" -ne 0 ]; then
  echo "❌ Jalankan sebagai root (sudo ./uninstall.sh)"
  exit
fi

echo "⚠️  PERINGATAN KERAS! ⚠️"
echo "Script ini akan MENGHAPUS SEMUA data website ArfCoder, Database, dan Software."
echo "VPS Anda akan dibersihkan kembali."
echo ""
read -p "Apakah Anda YAKIN 100% ingin melanjutkan? (ketik 'HAPUS SEMUA'): " CONFIRM

if [ "$CONFIRM" != "HAPUS SEMUA" ]; then
  echo "❌ Dibatalkan."
  exit
fi

echo ""
echo "🔥 Memulai proses pembersihan..."

# 1. Stop & Delete PM2 Processes
echo "🛑 Mematikan Aplikasi..."
if command -v pm2 &> /dev/null; then
    pm2 delete all
    pm2 save --force
    pm2 kill
fi

# 2. Hapus Project Files
echo "🗑️ Menghapus Folder Project..."
rm -rf /var/www/arfcoder
rm -rf /root/db_backups

# 3. Hapus Database PostgreSQL
echo "🗄️ Menghapus Database..."
# Mencoba drop database & user (abaikan error jika sudah tidak ada)
sudo -u postgres psql -c "DROP DATABASE arfcoder_db;" || true
sudo -u postgres psql -c "DROP USER arfcoder_user;" || true

# 4. Hapus Nginx Config & SSL
echo "🌐 Menghapus Konfigurasi Web Server..."
rm -f /etc/nginx/sites-enabled/arfcoder
rm -f /etc/nginx/sites-available/arfcoder
# Hapus sertifikat SSL (Opsional, simpan # jika ingin mempertahankan sertifikat)
certbot delete --cert-name arfzxdev.com --non-interactive || true
systemctl reload nginx

# 5. Hapus Cron Jobs (Backup Schedule)
echo "⏰ Membersihkan Jadwal Backup..."
crontab -l | grep -v "backup.sh" | crontab -

# 6. Hapus Rclone Config
echo "☁️ Menghapus Konfigurasi Rclone..."
rm -rf /root/.config/rclone

# 7. Uninstall Software (Opsional - Uncomment jika ingin benar-benar botak)
# Hati-hati, ini bisa menghapus software yang dipakai project lain di VPS yang sama!
echo "📦 Meng-uninstall Software (Node, Nginx, Postgres, Rclone)..."

read -p "❓ Apakah Anda ingin meng-uninstall Node.js, Nginx, Postgres & Rclone juga? (y/n): " UNINSTALL_SOFT
if [ "$UNINSTALL_SOFT" == "y" ]; then
    apt purge -y nodejs npm nginx postgresql* rclone certbot python3-certbot-nginx
    apt autoremove -y
    
    # Hapus sisa-sisa config global
    rm -rf /etc/nginx
    rm -rf /etc/postgresql
    rm -rf /usr/lib/node_modules
fi

# 8. Reset Firewall (Opsional)
# ufw reset
# ufw disable

echo ""
echo "=================================================="
echo "✨  PEMBERSIHAN SELESAI  ✨"
echo "VPS Anda sekarang bersih dari Project ArfCoder."
echo "=================================================="
