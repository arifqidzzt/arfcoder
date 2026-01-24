import { Router } from 'express';
import { register, login, verifyOtp, googleLogin } from '../controllers/authController';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/verify-otp', verifyOtp);
router.post('/google', googleLogin);

export default router;
