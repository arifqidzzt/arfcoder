import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middlewares/auth';
import { waService } from '../services/whatsappService';
import bcrypt from 'bcryptjs';

// Get Profile & Stats (With Auto-Cancel Logic)
export const getProfile = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;

    // 1. Lazy Auto-Cancel: Expire pending orders > 24 hours
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
    await prisma.order.updateMany({
      where: { 
        userId, 
        status: 'PENDING', 
        createdAt: { lt: yesterday } 
      },
      data: { status: 'CANCELLED' }
    });

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true, email: true, avatar: true, phoneNumber: true, role: true, twoFactorEnabled: true }
    });

    // 2. Calculate Spending (Include PAID, PROCESSING, SHIPPED, COMPLETED)
    const spending = await prisma.order.aggregate({
      _sum: { totalAmount: true },
      where: { 
        userId, 
        status: { in: ['PAID', 'PROCESSING', 'SHIPPED', 'COMPLETED'] } 
      }
    });

    res.json({ ...user, totalSpent: spending._sum.totalAmount || 0 });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// Update Profile (Photo & Basic Info)
export const updateProfile = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { name, avatar, phoneNumber } = req.body;
    
    const user = await prisma.user.update({
      where: { id: userId },
      data: { name, avatar, phoneNumber }
    });
    res.json(user);
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// Direct Phone Update (Bypass OTP for Admin Fix)
export const updatePhoneDirect = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { phoneNumber } = req.body;
    
    console.log(`Force Updating Phone for ${userId} to ${phoneNumber}`);

    const user = await prisma.user.update({
      where: { id: userId },
      data: { phoneNumber }
    });
    res.json(user);
  } catch (error) { 
    console.error(error);
    res.status(500).json({ message: 'Error updating phone', error }); 
  }
};

// Change Password
export const changePassword = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { oldPassword, newPassword } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.password) return res.status(400).json({ message: 'User not found' });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Password lama salah' });

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await prisma.user.update({ where: { id: userId }, data: { password: hashedPassword } });

    res.json({ message: 'Password berhasil diubah' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// --- EMAIL CHANGE FLOW ---
// 1. Request Change (Send OTP to OLD Email)
export const requestEmailChange = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    await prisma.otp.create({
      data: { code: otpCode, email: user.email, userId: user.id, expiresAt: new Date(Date.now() + 5 * 60 * 1000) }
    });

    // In production, send via Email Service (Resend)
    console.log(`OTP for Email Change (Old Email): ${otpCode}`); 
    res.json({ message: 'OTP dikirim ke email lama' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// 2. Verify Old Email OTP & Request New Email (Send OTP to NEW Email)
export const verifyOldEmail = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { code, newEmail } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    const otp = await prisma.otp.findFirst({ where: { userId, code, email: user?.email, expiresAt: { gt: new Date() } } });

    if (!otp) return res.status(400).json({ message: 'OTP Salah/Expired' });
    await prisma.otp.delete({ where: { id: otp.id } });

    // Send OTP to NEW Email
    const newOtpCode = Math.floor(100000 + Math.random() * 900000).toString();
    await prisma.otp.create({
      data: { code: newOtpCode, email: newEmail, userId: userId!, expiresAt: new Date(Date.now() + 5 * 60 * 1000) }
    });

    console.log(`OTP for Email Change (New Email ${newEmail}): ${newOtpCode}`);
    res.json({ message: 'Verifikasi berhasil. OTP dikirim ke email baru.' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// 3. Verify New Email & Update
export const verifyNewEmail = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { code, newEmail } = req.body;

    const otp = await prisma.otp.findFirst({ where: { userId, code, email: newEmail, expiresAt: { gt: new Date() } } });
    if (!otp) return res.status(400).json({ message: 'OTP Salah/Expired' });
    await prisma.otp.delete({ where: { id: otp.id } });

    await prisma.user.update({ where: { id: userId }, data: { email: newEmail } });
    res.json({ message: 'Email berhasil diubah!' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// --- PHONE CHANGE FLOW (WA OTP) ---

// 1. Request Change (Send OTP to OLD Phone if exists)
export const requestPhoneChange = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const user = await prisma.user.findUnique({ where: { id: userId } });
    
    // Jika belum punya no HP, langsung skip ke verifikasi nomor baru
    if (!user?.phoneNumber) {
      return res.json({ message: 'Langsung verifikasi nomor baru', skipOld: true });
    }

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    await waService.sendOTP(user.phoneNumber, otpCode);
    
    // Simpan OTP dengan ID unik (misal prefix old_)
    await prisma.otp.create({
      data: { code: otpCode, email: `old_${user.phoneNumber}`, userId: userId!, expiresAt: new Date(Date.now() + 5 * 60 * 1000) }
    });

    res.json({ message: 'OTP dikirim ke WhatsApp lama', skipOld: false });
  } catch (error) { res.status(500).json({ message: 'Gagal kirim WA', error }); }
};

// 2. Verify Old Phone OTP
export const verifyOldPhone = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { code } = req.body;
    const user = await prisma.user.findUnique({ where: { id: userId } });

    const otp = await prisma.otp.findFirst({ where: { userId, code, email: `old_${user?.phoneNumber}` } });
    if (!otp) return res.status(400).json({ message: 'OTP Salah' });
    
    await prisma.otp.delete({ where: { id: otp.id } });
    res.json({ message: 'Verifikasi berhasil. Masukkan nomor baru.' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// 3. Request New Phone OTP (Send to NEW Phone)
export const requestNewPhoneOtp = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { newPhoneNumber } = req.body;

    console.log(`Requesting OTP for new phone: ${newPhoneNumber}`);

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Kirim WA dulu sebelum simpan ke DB, biar kalau gagal gak nyampah di DB
    await waService.sendOTP(newPhoneNumber, otpCode);
    
    await prisma.otp.create({
      data: { code: otpCode, email: `new_${newPhoneNumber}`, userId: userId!, expiresAt: new Date(Date.now() + 5 * 60 * 1000) }
    });

    res.json({ message: 'OTP dikirim ke WhatsApp baru' });
  } catch (error: any) { 
    console.error('Controller Error:', error);
    res.status(500).json({ message: error.message || 'Gagal kirim WA ke nomor baru' }); 
  }
};

// 4. Verify New Phone & Update DB
export const verifyNewPhone = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { code, newPhoneNumber } = req.body;
    
    const otp = await prisma.otp.findFirst({ where: { userId, code, email: `new_${newPhoneNumber}` } });
    if (!otp) return res.status(400).json({ message: 'OTP Salah' });
    
    await prisma.otp.delete({ where: { id: otp.id } });
    await prisma.user.update({ where: { id: userId }, data: { phoneNumber: newPhoneNumber } });
    
    res.json({ message: 'Nomor WhatsApp berhasil disimpan!' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};
