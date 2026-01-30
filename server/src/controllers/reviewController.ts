import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middlewares/auth';

export const createReview = async (req: AuthRequest, res: Response) => {
  try {
    const { productId, rating, comment } = req.body;
    const userId = req.user?.userId;

    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    // 1. Cek apakah user sudah pernah beli dan status COMPLETED
    const hasPurchased = await prisma.order.findFirst({
      where: {
        userId,
        status: 'COMPLETED', // Hanya yang sudah selesai
        items: { some: { productId } }
      }
    });

    if (!hasPurchased) {
      return res.status(403).json({ message: 'Anda harus membeli produk ini sebelum memberi ulasan.' });
    }

    // 2. Cek apakah sudah pernah review
    const existing = await prisma.review.findFirst({
      where: { userId, productId }
    });

    if (existing) {
      return res.status(400).json({ message: 'Anda sudah mengulas produk ini.' });
    }

    const review = await prisma.review.create({
      data: {
        userId,
        productId,
        rating: Number(rating),
        comment
      }
    });

    res.status(201).json(review);
  } catch (error) {
    res.status(500).json({ message: 'Error creating review', error });
  }
};

export const getProductReviews = async (req: Request, res: Response) => {
  try {
    const { productId } = req.params;
    const reviews = await prisma.review.findMany({
      where: { productId: productId as string, isVisible: true },
      include: { user: { select: { name: true, avatar: true } } },
      orderBy: { createdAt: 'desc' }
    });
    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: 'Error' });
  }
};
