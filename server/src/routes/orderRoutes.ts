import { Router } from 'express';
import { createOrder, getMyOrders, handleMidtransWebhook, getOrderById, cancelOrder, requestRefund } from '../controllers/orderController';
import { authenticate } from '../middlewares/auth';

const router = Router();

router.post('/', authenticate, createOrder);
router.get('/my', authenticate, getMyOrders);
router.get('/:id', authenticate, getOrderById); // Detail Order
router.put('/:id/cancel', authenticate, cancelOrder); // Cancel
router.post('/:id/refund', authenticate, requestRefund); // Refund Request
router.post('/webhook', handleMidtransWebhook);

export default router;