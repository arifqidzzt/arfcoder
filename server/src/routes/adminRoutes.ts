import { Router } from 'express';
import {
  getDashboardStats, getAllOrders, updateOrderStatus, updateDeliveryInfo,
  getAllUsers, deleteUser,
  getUserChatHistory, getAdminServices, upsertService, deleteService,
  getWaStatus, logoutWa, startWa 
} from '../controllers/adminController';

// ... existing routes ...

// WA Control
router.get('/wa/status', getWaStatus);
router.post('/wa/logout', logoutWa);
router.post('/wa/start', startWa);

export default router;