import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

export const getProducts = async (req: Request, res: Response) => {
  try {
    const { category, search } = req.query;
    const products = await prisma.product.findMany({
      where: {
        ...(category ? { category: { name: category as string } } : {}),
        ...(search ? { name: { contains: search as string, mode: 'insensitive' } } : {}),
      },
      include: { category: true },
    });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const getProductById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const product = await prisma.product.findUnique({
      where: { id: id as string },
      include: { category: true },
    });
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const createProduct = async (req: Request, res: Response) => {
  try {
    const { name, description, price, discount, stock, type, images, categoryId } = req.body;
    const product = await prisma.product.create({
      data: { name, description, price, discount, stock, type, images, categoryId },
    });
    res.status(201).json(product);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const updateProduct = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const data = req.body;
    const product = await prisma.product.update({
      where: { id: id as string },
      data,
    });
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const deleteProduct = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.product.delete({ where: { id } });
    res.json({ message: 'Product deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

// --- NEW: Public Services Endpoint ---
export const getPublicServices = async (req: Request, res: Response) => {
  try {
    const services = await prisma.service.findMany({
      orderBy: { createdAt: 'desc' }
    });
    res.json(services);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};
