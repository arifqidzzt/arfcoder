import { Router } from 'express';
import { getDashboardStats, getAllOrders, updateOrderStatus, getAllUsers, deleteUser } from '../controllers/adminController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// All routes require ADMIN or SUPER_ADMIN role
router.use(authenticate, authorize(['ADMIN', 'SUPER_ADMIN']));

router.get('/stats', getDashboardStats);
router.get('/orders', getAllOrders);
router.put('/orders/:id', updateOrderStatus);
router.get('/users', getAllUsers);
router.delete('/users/:id', deleteUser);

export default router;
