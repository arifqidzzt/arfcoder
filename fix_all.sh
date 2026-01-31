#!/bin/bash

echo "🚀 MEMULAI PERBAIKAN TOTAL SISTEM..."

# 1. Server Fixes
echo "📦 [1/5] Updating Server Dependencies..."
cd /var/www/arfcoder/server
npm install --save-dev @types/speakeasy @types/qrcode @types/node
npx prisma generate
npx prisma db push

echo "🔨 [2/5] Building Backend..."
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Backend Build GAGAL! Periksa error di atas."
    exit 1
fi

# 2. Client Fixes
echo "🎨 [3/5] Building Frontend..."
cd ../client
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Frontend Build GAGAL! Periksa error di atas."
    exit 1
fi

# 3. Restart
echo "🔄 [4/5] Restarting PM2..."
cd ..
pm2 restart all

echo "✅ [5/5] SELESAI! Semua fitur sudah diperbaiki & aktif."
echo "   - Cek Bot WA: Ketik 'INFO VPS'"
echo "   - Cek 2FA: Logout & Login Admin"
