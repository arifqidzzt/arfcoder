import { Router } from 'express';
import { 
  getDashboardStats, getAllOrders, updateOrderStatus, 
  getAllUsers, deleteUser, updateDeliveryInfo,
  getUserChatHistory, getAdminServices, upsertService 
} from '../controllers/adminController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

router.use(authenticate, authorize(['ADMIN', 'SUPER_ADMIN']));

router.get('/stats', getDashboardStats);
router.get('/orders', getAllOrders);
router.put('/orders/:id', updateOrderStatus);
router.put('/orders/:id/delivery', updateDeliveryInfo);
router.get('/users', getAllUsers);
router.delete('/users/:id', deleteUser);

// Chat & Services
router.get('/chat/:userId', getUserChatHistory);
router.get('/services', getAdminServices);
router.post('/services', upsertService);

export default router;
