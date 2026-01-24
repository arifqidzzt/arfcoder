import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middlewares/auth';
const midtransClient = require('midtrans-client');

let snap = new midtransClient.Snap({
  isProduction: process.env.MIDTRANS_IS_PRODUCTION === 'true',
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY,
});

export const createOrder = async (req: AuthRequest, res: Response) => {
  try {
    const { items, address } = req.body;
    const userId = req.user?.userId;

    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    let totalAmount = 0;
    const orderItemsData = [];

    for (const item of items) {
      const product = await prisma.product.findUnique({ where: { id: item.productId } });
      if (!product) return res.status(404).json({ message: `Product ${item.productId} not found` });
      
      const price = product.price * (1 - product.discount / 100);
      totalAmount += price * item.quantity;
      orderItemsData.push({
        productId: product.id,
        quantity: item.quantity,
        price,
      });
    }

    const invoiceNumber = `INV-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

    const order = await prisma.order.create({
      data: {
        userId,
        invoiceNumber,
        totalAmount,
        address,
        items: {
          create: orderItemsData,
        },
      },
      include: { items: true },
    });

    // Create Midtrans Transaction
    const parameter = {
      transaction_details: {
        order_id: order.id,
        gross_amount: Math.round(totalAmount),
      },
      customer_details: {
        first_name: req.user?.userId, // Should ideally use user name
      },
    };

    try {
      const transaction = await snap.createTransaction(parameter);
      await prisma.order.update({
        where: { id: order.id },
        data: {
          snapToken: transaction.token,
          snapUrl: transaction.redirect_url,
        },
      });

      res.status(201).json({ order, snapToken: transaction.token, snapUrl: transaction.redirect_url });
    } catch (midtransError) {
      console.error('Midtrans Error:', midtransError);
      res.status(201).json({ order, message: 'Order created but failed to generate payment token' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const getMyOrders = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const orders = await prisma.order.findMany({
      where: { userId },
      include: { items: { include: { product: true } } },
      orderBy: { createdAt: 'desc' },
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};

export const handleMidtransWebhook = async (req: Request, res: Response) => {
  try {
    const statusResponse = req.body;
    const orderId = statusResponse.order_id;
    const transactionStatus = statusResponse.transaction_status;
    const fraudStatus = statusResponse.fraud_status;

    let orderStatus: any = 'PENDING';

    if (transactionStatus == 'capture') {
      if (fraudStatus == 'challenge') {
        orderStatus = 'PENDING';
      } else if (fraudStatus == 'accept') {
        orderStatus = 'PAID';
      }
    } else if (transactionStatus == 'settlement') {
      orderStatus = 'PAID';
    } else if (transactionStatus == 'cancel' || transactionStatus == 'deny' || transactionStatus == 'expire') {
      orderStatus = 'CANCELLED';
    } else if (transactionStatus == 'pending') {
      orderStatus = 'PENDING';
    }

    await prisma.order.update({
      where: { id: orderId },
      data: { status: orderStatus },
    });

    res.status(200).json({ message: 'Webhook received' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error });
  }
};
