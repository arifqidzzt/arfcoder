import { Request, Response } from 'express';
import speakeasy from 'speakeasy';
import QRCode from 'qrcode';
import { prisma } from '../lib/prisma';
import { generateToken, generateRefreshToken } from '../utils/jwt';
import { Resend } from 'resend';
import { waService } from '../services/whatsappService';

const resend = new Resend(process.env.RESEND_API_KEY);

// 1. Generate Secret & QR Code (For Setup)
export const setupTwoFactor = async (req: Request, res: Response) => {
  try {
    const { userId } = req.body; // In real app, get from req.user
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const secret = speakeasy.generateSecret({
      name: `ArfCoder (${user.email})`,
    });

    // Save temporary secret to DB (or session) - Here we assume immediate verify
    // For safety, we should verify before saving permanently. 
    // But for simplicity, we send secret to frontend to verify.
    
    // Better flow: Save secret to user but set enabled=false
    await prisma.user.update({
      where: { id: userId },
      data: { twoFactorSecret: secret.base32, twoFactorEnabled: false }
    });

    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url || '');

    res.json({ secret: secret.base32, qrCode: qrCodeUrl });
  } catch (error) {
    res.status(500).json({ message: 'Error setting up 2FA', error });
  }
};

// 2. Verify & Enable 2FA
export const enableTwoFactor = async (req: Request, res: Response) => {
  try {
    const { userId, token } = req.body;
    const user = await prisma.user.findUnique({ where: { id: userId } });
    
    if (!user || !user.twoFactorSecret) {
      return res.status(400).json({ message: '2FA setup not initiated' });
    }

    const verified = speakeasy.totp.verify({
      secret: user.twoFactorSecret,
      encoding: 'base32',
      token: token
    });

    if (verified) {
      await prisma.user.update({
        where: { id: userId },
        data: { twoFactorEnabled: true }
      });
      res.json({ message: '2FA berhasil diaktifkan!' });
    } else {
      res.status(400).json({ message: 'Kode OTP salah. Coba lagi.' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error verifying 2FA', error });
  }
};

// 3. Login Verify (Universal: TOTP or DB OTP)
export const verifyLogin2FA = async (req: Request, res: Response) => {
  try {
    const { userId, code, method } = req.body; // method: 'authenticator', 'email', 'whatsapp'

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    let verified = false;

    if (method === 'authenticator') {
      if (!user.twoFactorSecret) return res.status(400).json({ message: 'Google Auth belum diaktifkan' });
      verified = speakeasy.totp.verify({
        secret: user.twoFactorSecret,
        encoding: 'base32',
        token: code,
        window: 1 // Allow 30s drift
      });
    } else {
      // Check DB OTP (Email/WA)
      const otp = await prisma.otp.findFirst({
        where: { userId, code, expiresAt: { gt: new Date() } }
      });
      if (otp) {
        verified = true;
        await prisma.otp.delete({ where: { id: otp.id } });
      }
    }

    if (verified) {
      const token = generateToken(user.id, user.role);
      const refreshToken = generateRefreshToken(user.id);
      
      res.json({
        token,
        refreshToken,
        user: { id: user.id, email: user.email, name: user.name, role: user.role }
      });
    } else {
      res.status(400).json({ message: 'Kode Verifikasi Salah' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error login 2FA', error });
  }
};

// 4. Send Backup OTP (Email/WA)
export const sendBackupOtp = async (req: Request, res: Response) => {
  try {
    const { userId, method } = req.body; // 'email' or 'whatsapp'
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Clear old
    await prisma.otp.deleteMany({ where: { userId } });
    
    // Save new
    await prisma.otp.create({
      data: {
        code: otpCode,
        userId: user.id,
        email: user.email,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000)
      }
    });

    if (method === 'email') {
      await resend.emails.send({
        from: process.env.EMAIL_FROM || 'onboarding@resend.dev',
        to: user.email,
        subject: 'Login OTP - ArfCoder',
        html: `<h1>${otpCode}</h1><p>Gunakan kode ini untuk login.</p>`
      });
    } else if (method === 'whatsapp') {
      // Check if user has phone number
      if (!user.phoneNumber) {
        // Fallback: Try to find number in profile or assume email is not number
        // Here we just return error if no phone
        return res.status(400).json({ message: 'Nomor WhatsApp belum diset di profile' });
      }
      
      // Use Baileys Service
      // Format number: 08xx -> 628xx
      let phone = user.phoneNumber.replace(/\D/g, '');
      if (phone.startsWith('0')) phone = '62' + phone.slice(1);
      
      const sent = await waService.sendMessage(`${phone}@s.whatsapp.net`, `Kode Login ArfCoder: *${otpCode}*`);
      if (!sent) return res.status(500).json({ message: 'Gagal mengirim WhatsApp. Bot mungkin offline.' });
    }

    res.json({ message: `OTP dikirim ke ${method}` });
  } catch (error) {
    res.status(500).json({ message: 'Error sending OTP', error });
  }
};
