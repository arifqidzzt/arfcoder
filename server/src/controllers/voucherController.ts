import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { z } from 'zod';

// Schema Validation
const voucherSchema = z.object({
  code: z.string().min(3).toUpperCase(),
  type: z.enum(['PERCENT', 'FIXED']),
  value: z.number().min(0),
  minPurchase: z.number().min(0).default(0),
  maxDiscount: z.number().optional(),
  expiresAt: z.string().transform((str) => new Date(str)),
  usageLimit: z.number().min(0).default(0),
});

// --- ADMIN ---

export const createVoucher = async (req: Request, res: Response) => {
  try {
    const data = voucherSchema.parse(req.body);
    
    // Check duplicate
    const existing = await prisma.voucher.findUnique({ where: { code: data.code } });
    if (existing) return res.status(400).json({ message: 'Kode voucher sudah ada' });

    const voucher = await prisma.voucher.create({ data });
    res.status(201).json(voucher);
  } catch (error) {
    res.status(400).json({ message: 'Invalid data', error });
  }
};

export const getAllVouchers = async (req: Request, res: Response) => {
  try {
    const vouchers = await prisma.voucher.findMany({
      orderBy: { createdAt: 'desc' }
    });
    res.json(vouchers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching vouchers' });
  }
};

export const deleteVoucher = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.voucher.delete({ where: { id: id as string } });
    res.json({ message: 'Voucher deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting voucher' });
  }
};

// --- USER ---

export const checkVoucher = async (req: Request, res: Response) => {
  try {
    const { code, totalAmount } = req.body;
    
    if (!code) return res.status(400).json({ message: 'Code required' });

    const voucher = await prisma.voucher.findUnique({ where: { code } });

    // 1. Validasi Dasar
    if (!voucher) return res.status(404).json({ message: 'Voucher tidak ditemukan' });
    if (!voucher.isActive) return res.status(400).json({ message: 'Voucher tidak aktif' });
    if (new Date() > voucher.expiresAt) return res.status(400).json({ message: 'Voucher kedaluwarsa' });
    if (voucher.usageLimit > 0 && voucher.usedCount >= voucher.usageLimit) {
      return res.status(400).json({ message: 'Kuota voucher habis' });
    }
    if (totalAmount < voucher.minPurchase) {
      return res.status(400).json({ message: `Minimal belanja Rp${voucher.minPurchase.toLocaleString('id-ID')}` });
    }

    // 2. Hitung Diskon
    let discountAmount = 0;
    if (voucher.type === 'FIXED') {
      discountAmount = voucher.value;
    } else {
      discountAmount = (totalAmount * voucher.value) / 100;
      if (voucher.maxDiscount && discountAmount > voucher.maxDiscount) {
        discountAmount = voucher.maxDiscount;
      }
    }

    // Pastikan diskon tidak melebihi total belanja
    if (discountAmount > totalAmount) discountAmount = totalAmount;

    res.json({
      valid: true,
      voucher,
      discountAmount,
      finalAmount: totalAmount - discountAmount
    });

  } catch (error) {
    res.status(500).json({ message: 'Error checking voucher' });
  }
};
