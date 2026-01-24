import { Router } from 'express';
import {
  getDashboardStats, getAllOrders, updateOrderStatus,
  getAllUsers, deleteUser, updateDeliveryInfo,
  getUserChatHistory, getAdminServices, upsertService, deleteService 
} from '../controllers/adminController';

// ...
router.get('/services', getAdminServices);
router.post('/services', upsertService);
router.delete('/services/:id', deleteService);

export default router;
