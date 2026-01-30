import { Router } from 'express';
import { register, login, verifyOtp, googleLogin, forgotPassword, resetPassword, resendOtp, verifyLoginOtp } from '../controllers/authController';
import { setupTwoFactor, enableTwoFactor, verifyLogin2FA, sendBackupOtp } from '../controllers/twoFactorController';
import { authenticate } from '../middlewares/auth';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/verify-otp', verifyOtp);
router.post('/resend-otp', resendOtp);
router.post('/google', googleLogin);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// 2FA Routes
router.post('/2fa/verify', verifyLogin2FA); // Login Step 2
router.post('/2fa/send', sendBackupOtp);    // Request OTP (Email/WA)

// 2FA Setup (Protected)
router.post('/2fa/setup', authenticate, setupTwoFactor);
router.post('/2fa/enable', authenticate, enableTwoFactor);

export default router;
router.post('/google', googleLogin);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

export default router;
