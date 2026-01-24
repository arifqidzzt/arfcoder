import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../lib/prisma';
import { generateToken, generateRefreshToken } from '../utils/jwt';
import { Resend } from 'resend';
import { OAuth2Client } from 'google-auth-library';

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

    // Generate & Send Real OTP via Resend
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    await prisma.otp.create({
      data: {
        code: otpCode,
        email,
        userId: user.id,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
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
      // Fallback log if email fails (e.g. invalid API Key)
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
    
    // Verify token with Google
    const ticket = await googleClient.verifyIdToken({
      idToken: googleToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    
    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      return res.status(400).json({ message: 'Invalid Google Token' });
    }

    const { email, name, sub: googleId } = payload;

    // Check if user exists
    let user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      // Create new user from Google
      user = await prisma.user.create({
        data: {
          email,
          name: name || 'User',
          googleId,
          isVerified: true, // Auto verify for Google
          role: 'USER',
        },
      });
    } else if (!user.googleId) {
      // Link existing account
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