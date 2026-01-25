import { Router } from 'express';
import { getProducts, getProductById, createProduct, updateProduct, deleteProduct, getPublicServices } from '../controllers/productController';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

router.get('/services', getPublicServices); // PUBLIC ROUTE
router.get('/', getProducts);
router.get('/:id', getProductById);

// Admin only routes
router.post('/', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), createProduct);
router.put('/:id', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), updateProduct);
router.delete('/:id', authenticate, authorize(['ADMIN', 'SUPER_ADMIN']), deleteProduct);

export default router;
