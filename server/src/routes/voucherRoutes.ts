import { Router } from 'express';
import { createVoucher, getAllVouchers, deleteVoucher, checkVoucher } from '../controllers/voucherController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// Public (Check only)
router.post('/check', authenticate, checkVoucher);

// Admin Management
router.get('/', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), getAllVouchers);
router.post('/', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), createVoucher);
router.delete('/:id', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), deleteVoucher);

export default router;
