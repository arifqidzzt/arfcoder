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

    const parameter = {
      transaction_details: {
        order_id: order.id,
        gross_amount: Math.round(totalAmount),
      },
      customer_details: {
        first_name: req.user?.userId, 
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

// New Function: Get Single Order Detail
export const getOrderById = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    
    // Explicitly cast id to string to satisfy TS
    const orderId = id as string;

    const whereClause: any = req.user?.role === 'ADMIN' || req.user?.role === 'SUPER_ADMIN' 
      ? { id: orderId } 
      : { id: orderId, userId };

    const order = await prisma.order.findFirst({
      where: whereClause,
      include: { 
        items: { include: { product: true } },
        user: { select: { name: true, email: true } }
      }
    });

    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error', error });
  }
};

// New Function: Cancel Order
export const cancelOrder = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const orderId = id as string;

    const order = await prisma.order.findFirst({ where: { id: orderId, userId } });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (order.status !== 'PENDING') return res.status(400).json({ message: 'Cannot cancel processed order' });

    await prisma.order.update({
      where: { id: orderId },
      data: { status: 'CANCELLED' }
    });

    res.json({ message: 'Order cancelled' });
  } catch (error) {
    res.status(500).json({ message: 'Error', error });
  }
};

// New Function: Request Refund
export const requestRefund = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { reason, account } = req.body;
    const userId = req.user?.userId;
    const orderId = id as string;

    const order = await prisma.order.findFirst({ where: { id: orderId, userId } });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (order.status !== 'PAID') return res.status(400).json({ message: 'Only paid orders can be refunded' });

    await prisma.order.update({
      where: { id: orderId },
      data: { 
        status: 'REFUND_REQUESTED',
        refundReason: reason,
        refundAccount: account
      }
    });

    res.json({ message: 'Refund requested' });
  } catch (error) {
    res.status(500).json({ message: 'Error', error });
  }
};

export const handleMidtransWebhook = async (req: Request, res: Response) => {
  try {
    console.log('--- WEBHOOK RECEIVED ---');
    console.log('Body:', req.body); 

    const statusResponse = req.body;
    const orderId = statusResponse.order_id;
    const transactionStatus = statusResponse.transaction_status;
    const fraudStatus = statusResponse.fraud_status;

    console.log(`Processing Order ID: ${orderId} | Status: ${transactionStatus}`);

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

    // UPDATE DATABASE
    await prisma.order.update({
      where: { id: orderId },
      data: { status: orderStatus },
    });

    console.log(`Order ${orderId} updated to ${orderStatus}`);
    res.status(200).json({ message: 'Webhook received', status: orderStatus });
  } catch (error) {
    console.error('WEBHOOK ERROR:', error); 
    res.status(500).json({ message: 'Internal server error', error });
  }
};
