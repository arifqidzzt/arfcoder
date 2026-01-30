import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { z } from 'zod';

const flashSaleSchema = z.object({
  productId: z.string(),
  discountPrice: z.number().min(0),
  startTime: z.string().transform(s => new Date(s)),
  endTime: z.string().transform(s => new Date(s)),
});

export const createFlashSale = async (req: Request, res: Response) => {
  try {
    const data = flashSaleSchema.parse(req.body);
    
    // Check overlapping (optional, skipping for speed)
    
    const fs = await prisma.flashSale.create({ data });
    res.status(201).json(fs);
  } catch (error) {
    res.status(400).json({ message: 'Invalid data', error });
  }
};

export const getActiveFlashSales = async (req: Request, res: Response) => {
  try {
    const now = new Date();
    const flashSales = await prisma.flashSale.findMany({
      where: {
        isActive: true,
        startTime: { lte: now },
        endTime: { gt: now }
      },
      include: { product: true },
      orderBy: { endTime: 'asc' }
    });
    res.json(flashSales);
  } catch (error) {
    res.status(500).json({ message: 'Error' });
  }
};

export const getAllFlashSales = async (req: Request, res: Response) => {
  try {
    const flashSales = await prisma.flashSale.findMany({
      include: { product: true },
      orderBy: { createdAt: 'desc' }
    });
    res.json(flashSales);
  } catch (error) {
    res.status(500).json({ message: 'Error' });
  }
};

export const deleteFlashSale = async (req: Request, res: Response) => {
  try {
    await prisma.flashSale.delete({ where: { id: req.params.id } });
    res.json({ message: 'Deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error' });
  }
};
