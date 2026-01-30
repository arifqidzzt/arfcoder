import { prisma } from '../lib/prisma';

export const logActivity = async (userId: string, action: string, details?: string, ipAddress?: string) => {
  try {
    await prisma.activityLog.create({
      data: {
        userId,
        action,
        details,
        ipAddress
      }
    });
  } catch (error) {
    console.error('Failed to log activity:', error);
  }
};
