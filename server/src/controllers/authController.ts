import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../lib/prisma';
import { generateToken, generateRefreshToken } from '../utils/jwt';
import { Resend } from 'resend';
import { OAuth2Client } from 'google-auth-library';
import crypto from 'crypto';

const resend = new Resend(process.env.RESEND_API_KEY);
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const register = async (req: Request, res: Response) => {
  try {
    const { email, password, name } = req.body;

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
        role: 'USER',
      },
    });

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    await prisma.otp.create({
      data: {
        code: otpCode,
        email,
        userId: user.id,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      },
    });

    try {
      await resend.emails.send({
        from: process.env.EMAIL_FROM || 'onboarding@resend.dev',
        to: email,
        subject: 'Verifikasi Email ArfCoder',
        html: `<p>Halo ${name},</p><p>Kode verifikasi Anda adalah: <strong>${otpCode}</strong></p><p>Kode ini berlaku selama 5 menit.</p>`,
      });
      console.log(`Email OTP sent to ${email}`);
    } catch (emailError) {
      console.error('Resend Error:', emailError);
      console.log(`Fallback OTP for ${email}: ${otpCode}`);
    }

    res.status(201).json({ message: 'User registered. Please check your email.', userId: user.id });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const verifyOtp = async (req: Request, res: Response) => {
  try {
    const { userId, code } = req.body;

    const otp = await prisma.otp.findFirst({
      where: { userId, code, expiresAt: { gt: new Date() } },
    });

    if (!otp) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    await prisma.user.update({
      where: { id: userId },
      data: { isVerified: true },
    });

    await prisma.otp.delete({ where: { id: otp.id } });

    res.status(200).json({ message: 'Email verified successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.password) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    if (!user.isVerified) {
      return res.status(403).json({ message: 'Please verify your email first', userId: user.id });
    }

    // --- ADMIN 2FA CHECK ---
    if (user.role === 'ADMIN' || user.role === 'SUPER_ADMIN') {
      const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
      
      // Clear old OTPs
      await prisma.otp.deleteMany({ where: { userId: user.id } });

      await prisma.otp.create({
        data: {
          code: otpCode,
          email: user.email,
          userId: user.id,
          expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 Minutes
        },
      });

      try {
        await resend.emails.send({
          from: process.env.EMAIL_FROM || 'onboarding@resend.dev',
          to: user.email,
          subject: '🔐 Admin Login OTP - ArfCoder',
          html: `
            <h3>Login Admin Verification</h3>
            <p>Halo Admin ${user.name},</p>
            <p>Gunakan kode OTP berikut untuk masuk:</p>
            <h1 style="letter-spacing: 5px;">${otpCode}</h1>
            <p>Jangan berikan kode ini kepada siapapun.</p>
          `,
        });
      } catch (e) {
        console.error('Failed to send Admin OTP:', e);
        // Fallback or Log
      }

      return res.status(202).json({ 
        require2fa: true, 
        userId: user.id, 
        email: user.email,
        message: 'OTP sent to admin email'
      });
    }
    // -----------------------

    const token = generateToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    res.status(200).json({
      token,
      refreshToken,
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const googleLogin = async (req: Request, res: Response) => {
  try {
    const { token: googleToken } = req.body;
    
    const ticket = await googleClient.verifyIdToken({
      idToken: googleToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    
    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      return res.status(400).json({ message: 'Invalid Google Token' });
    }

    const { email, name, sub: googleId } = payload;

    let user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      user = await prisma.user.create({
        data: {
          email,
          name: name || 'User',
          googleId,
          isVerified: true,
          role: 'USER',
        },
      });
    } else if (!user.googleId) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId, isVerified: true },
      });
    }

    const token = generateToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    res.status(200).json({
      token,
      refreshToken,
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    });

  } catch (error) {
    console.error('Google Login Error:', error);
    res.status(500).json({ message: 'Google login failed', error });
  }
};

export const resendOtp = async (req: Request, res: Response) => {
  try {
    const { userId, email } = req.body;
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    await prisma.otp.deleteMany({ where: { userId, email } }); // Clear old ones
    
    await prisma.otp.create({
      data: {
        code: otpCode,
        email,
        userId,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      },
    });

    try {
      await resend.emails.send({
        from: process.env.EMAIL_FROM || 'onboarding@resend.dev',
        to: email,
        subject: 'Kode Verifikasi Baru ArfCoder',
        html: `<p>Kode verifikasi baru Anda: <strong>${otpCode}</strong></p>`,
      });
    } catch (e) {
      console.log(`Resend OTP fallback: ${otpCode}`);
    }

    res.json({ message: 'Kode OTP baru telah dikirim' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

export const forgotPassword = async (req: Request, res: Response) => {
  try {
    const { email } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.status(404).json({ message: 'Email tidak terdaftar' });

    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenExpiry = new Date(Date.now() + 3600000); // 1 Hour

    await prisma.user.update({
      where: { id: user.id },
      data: { resetToken, resetTokenExpiry }
    });

    const resetUrl = `${process.env.CLIENT_URL}/reset-password?token=${resetToken}`;
    console.log(`Reset Link for ${email}: ${resetUrl}`); 
    
    // Kirim Email Asli
    try {
      const { data, error } = await resend.emails.send({
        from: process.env.EMAIL_FROM || 'onboarding@resend.dev',
        to: email,
        subject: 'Permintaan Ganti Password - ArfCoder',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #000;">Halo, ${user.name || 'User'}</h2>
            <p>Kami menerima permintaan untuk mengatur ulang kata sandi akun ArfCoder Anda.</p>
            <p>Jika ini benar Anda, silakan klik tombol di bawah ini:</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${resetUrl}" style="background-color: #000; color: #fff; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold;">Ganti Password Saya</a>
            </div>
            <p style="color: #666; font-size: 14px;">Tautan ini hanya berlaku selama 1 jam.</p>
            <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
            <p style="color: #999; font-size: 12px;">Jika Anda tidak merasa melakukan permintaan ini, mohon abaikan email ini.</p>
          </div>
        `
      });
      
      if (error) {
        console.error('Resend Error:', error);
        return res.status(500).json({ message: 'Gagal mengirim email provider' });
      }
    } catch (e) {
      console.error('Email Send Exception:', e);
    }

    res.json({ message: 'Link reset dikirim ke email' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

export const resetPassword = async (req: Request, res: Response) => {
  try {
    const { token, newPassword } = req.body;
    
    const user = await prisma.user.findFirst({
      where: { 
        resetToken: token, 
        resetTokenExpiry: { gt: new Date() } 
      }
    });

    if (!user) return res.status(400).json({ message: 'Token invalid atau expired' });

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await prisma.user.update({
      where: { id: user.id },
      data: { password: hashedPassword, resetToken: null, resetTokenExpiry: null }
    });

    res.json({ message: 'Password berhasil direset' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

export const verifyLoginOtp = async (req: Request, res: Response) => {
  try {
    const { userId, code } = req.body;

    const otp = await prisma.otp.findFirst({
      where: { userId, code, expiresAt: { gt: new Date() } },
    });

    if (!otp) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Generate Tokens
    const token = generateToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    // Clean up OTP
    await prisma.otp.delete({ where: { id: otp.id } });

    res.status(200).json({
      token,
      refreshToken,
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};
