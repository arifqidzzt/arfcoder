import { Router } from 'express';
import { getProfile, updateProfile, changePassword, requestEmailChange, verifyOldEmail, verifyNewEmail, requestPhoneChange, verifyOldPhone, requestNewPhoneOtp, verifyNewPhone } from '../controllers/userController';
import { authenticate } from '../middlewares/auth';

const router = Router();

router.use(authenticate);

router.get('/profile', getProfile);
router.put('/profile', updateProfile);
router.put('/password', changePassword);

// Email Change
router.post('/email/request', requestEmailChange);
router.post('/email/verify-old', verifyOldEmail);
router.post('/email/verify-new', verifyNewEmail);

// WA Phone Change
router.post('/phone/request', requestPhoneChange);
router.post('/phone/verify-old', verifyOldPhone);
router.post('/phone/request-new', requestNewPhoneOtp);
router.post('/phone/verify-new', verifyNewPhone);

export default router;
