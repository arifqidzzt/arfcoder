import { Router } from 'express';
import { getLogs } from '../controllers/logController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

router.get('/', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), getLogs);

export default router;
