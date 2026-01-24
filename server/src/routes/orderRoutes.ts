import { Router } from 'express';
import { createOrder, getMyOrders, handleMidtransWebhook } from '../controllers/orderController';
import { authenticate } from '../middlewares/auth';

const router = Router();

router.post('/', authenticate, createOrder);
router.get('/my', authenticate, getMyOrders);
router.post('/webhook', handleMidtransWebhook);

export default router;
