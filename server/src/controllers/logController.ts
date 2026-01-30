import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

export const getLogs = async (req: Request, res: Response) => {
  try {
    const logs = await prisma.activityLog.findMany({
      include: { user: { select: { name: true, email: true, role: true } } },
      orderBy: { createdAt: 'desc' },
      take: 100 // Limit 100 latest
    });
    res.json(logs);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching logs' });
  }
};
