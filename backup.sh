#!/bin/bash

# ==========================================
# ARFCODER AUTO BACKUP TO GOOGLE DRIVE
# ==========================================

# Konfigurasi - SESUAIKAN DENGAN SETUP ANDA
DB_NAME="arfcoder"
DB_USER="arfcoder_user"
REMOTE_NAME="gdrive" 
REMOTE_FOLDER="arfcoder_backups" 
BACKUP_DIR="/root/db_backups"
TIMESTAMP=$(date +%F-%H%M)

# Password Database (Akan diisi otomatis oleh setup.sh atau isi manual di sini)
export PGPASSWORD=''

mkdir -p $BACKUP_DIR

echo "📦 Memulai backup database..."

# 1. Dump Database ke file .sql
pg_dump -U $DB_USER -h localhost $DB_NAME > $BACKUP_DIR/backup-$TIMESTAMP.sql

# 2. Upload ke Google Drive via Rclone
if command -v rclone &> /dev/null; then
    rclone copy $BACKUP_DIR/backup-$TIMESTAMP.sql $REMOTE_NAME:$REMOTE_FOLDER
    echo "✅ Backup berhasil diupload ke Google Drive."
else
    echo "❌ Rclone tidak ditemukan. Backup hanya tersimpan lokal."
fi

# 3. Hapus backup lokal yang lebih tua dari 3 hari agar disk tidak penuh
find $BACKUP_DIR -type f -mtime +3 -name "*.sql" -delete

echo "🚀 Selesai."