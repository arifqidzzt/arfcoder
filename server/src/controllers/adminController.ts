import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middlewares/auth';

// ... (stats, orders, etc remain same)

// --- CHAT ---
export const getUserChatHistory = async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;
    const messages = await prisma.message.findMany({
      where: { 
        OR: [
          { senderId: userId }, 
          { senderId: req.user?.userId, isAdmin: true }
        ] 
      },
      orderBy: { createdAt: 'asc' }
    });
    res.json(messages);
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

// --- SERVICES ---
export const getAdminServices = async (req: Request, res: Response) => {
  try {
    const services = await prisma.service.findMany({ orderBy: { createdAt: 'desc' } });
    res.json(services);
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};

export const upsertService = async (req: Request, res: Response) => {
  try {
    const { id, title, description, price, icon } = req.body;
    const service = await prisma.service.upsert({
      where: { id: id || 'new' },
      update: { title, description, price, icon },
      create: { title, description, price, icon }
    });
    res.json(service);
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};
