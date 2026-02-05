-- 1. Buat tipe Enum untuk Mode Midtrans
CREATE TYPE "MidtransMode" AS ENUM ('SNAP', 'CORE');

-- 2. Buat tabel PaymentSetting
CREATE TABLE "PaymentSetting" (
    "id" TEXT NOT NULL,
    "mode" "MidtransMode" NOT NULL DEFAULT 'SNAP',
    "activeMethods" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "PaymentSetting_pkey" PRIMARY KEY ("id")
);

-- 3. Tambah kolom ke tabel Product
ALTER TABLE "Product" ADD COLUMN "paymentMethods" TEXT[];

-- 4. Tambah kolom ke tabel Order
ALTER TABLE "Order" ADD COLUMN "paymentMethod" TEXT;
ALTER TABLE "Order" ADD COLUMN "paymentDetails" JSONB;
