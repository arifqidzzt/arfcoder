import { Router } from 'express';
import { createFlashSale, deleteFlashSale, getActiveFlashSales, getAllFlashSales } from '../controllers/flashSaleController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// Public
router.get('/active', getActiveFlashSales);

// Admin
router.get('/', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), getAllFlashSales);
router.post('/', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), createFlashSale);
router.delete('/:id', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), deleteFlashSale);

export default router;
