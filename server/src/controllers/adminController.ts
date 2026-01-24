import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middlewares/auth';

// --- STATS ---
export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const totalOrders = await prisma.order.count();
    const totalProducts = await prisma.product.count();
    const totalUsers = await prisma.user.count();
    
    // Sum total sales from PAID orders
    const salesData = await prisma.order.aggregate({
      _sum: {
        totalAmount: true,
      },
      where: {
        status: 'PAID',
      },
    });

    res.json({
      totalOrders,
      totalProducts,
      totalUsers,
      totalSales: salesData._sum.totalAmount || 0,
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

// --- ORDERS ---
export const getAllOrders = async (req: Request, res: Response) => {
  try {
    const orders = await prisma.order.findMany({
      include: {
        user: { select: { name: true, email: true } },
        items: { include: { product: true } }
      },
      orderBy: { createdAt: 'desc' },
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const updateOrderStatus = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { status, refundProof } = req.body;
    
    const order = await prisma.order.update({
      where: { id: id as string },
      data: { status, refundProof },
    });
    
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const updateDeliveryInfo = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { deliveryInfo } = req.body;
    
    const order = await prisma.order.update({
      where: { id: id as string },
      data: { deliveryInfo, status: 'SHIPPED' },
    });
    
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

// --- USERS ---
export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const users = await prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      select: { id: true, name: true, email: true, role: true, isVerified: true, createdAt: true }
    });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.user.delete({ where: { id: id as string } });
    res.json({ message: 'User deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

// --- CHAT ---
export const getUserChatHistory = async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;
    const messages = await prisma.message.findMany({
      where: { 
        OR: [
          { senderId: userId as string }, 
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

export const deleteService = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.service.delete({ where: { id } });
    res.json({ message: 'Service deleted' });
  } catch (error) { res.status(500).json({ message: 'Error', error }); }
};