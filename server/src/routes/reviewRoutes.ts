import { Router } from 'express';
import { createReview, getProductReviews } from '../controllers/reviewController';
import { authenticate } from '../middlewares/auth';

const router = Router();

// Public
router.get('/:productId', getProductReviews);

// Protected (Must buy first)
router.post('/', authenticate, createReview);

export default router;
