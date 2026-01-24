import { prisma } from '../lib/prisma';

export const saveMessage = async (content: string, senderId: string, isAdmin: boolean) => {
  return await prisma.message.create({
    data: {
      content,
      senderId,
      isAdmin,
    },
    include: { sender: { select: { name: true, email: true } } },
  });
};

export const getChatHistory = async (userId: string) => {
  return await prisma.message.findMany({
    where: {
      OR: [
        { senderId: userId },
        { isAdmin: true }, // Simple logic: users see all admin messages for now, or filter better
      ],
    },
    orderBy: { createdAt: 'asc' },
  });
};
