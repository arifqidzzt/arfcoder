import { Router } from 'express';
import { 
  getDashboardStats, getAllOrders, updateOrderStatus, updateDeliveryInfo,
  getAllUsers, deleteUser,
  getUserChatHistory, getAdminServices, upsertService, deleteService 
} from '../controllers/adminController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// All routes require ADMIN or SUPER_ADMIN role
router.use(authenticate, authorize(['ADMIN', 'SUPER_ADMIN']));

// Stats
router.get('/stats', getDashboardStats);

// Orders
router.get('/orders', getAllOrders);
router.put('/orders/:id', updateOrderStatus);
router.put('/orders/:id/delivery', updateDeliveryInfo);

// Users
router.get('/users', getAllUsers);
router.delete('/users/:id', deleteUser);

// Chat
router.get('/chat/:userId', getUserChatHistory);

// Services
router.get('/services', getAdminServices);
router.post('/services', upsertService);
router.delete('/services/:id', deleteService);

export default router;