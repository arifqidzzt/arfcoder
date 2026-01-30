import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middlewares/auth';
const midtransClient = require('midtrans-client');

let snap = new midtransClient.Snap({
  isProduction: process.env.MIDTRANS_IS_PRODUCTION === 'true',
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY,
});

// ... (createOrder, getMyOrders, getOrderById tetap sama)

export const createOrder = async (req: AuthRequest, res: Response) => {
  try {
    const { items, address, voucherCode } = req.body;
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

    // --- APPLY VOUCHER (Backend Validation) ---
    let discountApplied = 0;
    if (voucherCode) {
      const voucher = await prisma.voucher.findUnique({ where: { code: voucherCode } });
      if (voucher && voucher.isActive && new Date() <= voucher.expiresAt) {
        if (voucher.usageLimit === 0 || voucher.usedCount < voucher.usageLimit) {
          if (totalAmount >= voucher.minPurchase) {
            if (voucher.type === 'FIXED') {
              discountApplied = voucher.value;
            } else {
              discountApplied = (totalAmount * voucher.value) / 100;
              if (voucher.maxDiscount && discountApplied > voucher.maxDiscount) {
                discountApplied = voucher.maxDiscount;
              }
            }
            // Update Voucher Usage
            await prisma.voucher.update({
              where: { id: voucher.id },
              data: { usedCount: { increment: 1 } }
            });
          }
        }
      }
    }

    const finalAmount = Math.max(0, totalAmount - discountApplied);
    const invoiceNumber = `INV-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

    const order = await prisma.order.create({
      data: {
        userId,
        invoiceNumber,
        totalAmount: finalAmount,
        discountApplied,
        voucherCode,
        address,
        items: {
          create: orderItemsData,
        },
      },
      include: { items: true },
    });

    // Kurangi Stok
    for (const item of orderItemsData) {
      await prisma.product.update({
        where: { id: item.productId },
        data: { stock: { decrement: item.quantity } }
      });
    }

    const parameter = {
      transaction_details: {
        order_id: order.id,
        gross_amount: Math.round(finalAmount),
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

export const getOrderById = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const orderId = id as string;

    const whereClause: any = req.user?.role === 'ADMIN' || req.user?.role === 'SUPER_ADMIN' 
      ? { id: orderId } 
      : { id: orderId, userId };

    const order = await prisma.order.findFirst({
      where: whereClause,
      include: { 
        items: { include: { product: true } },
        user: { select: { name: true, email: true } },
        timeline: { orderBy: { timestamp: 'desc' } }
      }
    });

    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error', error });
  }
};

export const cancelOrder = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const orderId = id as string;

    const order = await prisma.order.findFirst({ where: { id: orderId, userId }, include: { items: true } });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (order.status !== 'PENDING') return res.status(400).json({ message: 'Cannot cancel processed order' });

    // Return Stock
    await prisma.$transaction([
      prisma.order.update({
        where: { id: orderId },
        data: { status: 'CANCELLED' }
      }),
      ...order.items.map(item => 
        prisma.product.update({
          where: { id: item.productId },
          data: { stock: { increment: item.quantity } }
        })
      )
    ]);

    res.json({ message: 'Order cancelled' });
  } catch (error) {
    res.status(500).json({ message: 'Error', error });
  }
};

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

// --- NEW FUNCTION: REGENERATE SNAP TOKEN (SMART) ---
export const regeneratePaymentToken = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const orderId = id as string;

    const order = await prisma.order.findFirst({ where: { id: orderId, userId } });
    
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (order.status !== 'PENDING') return res.status(400).json({ message: 'Order already paid/cancelled' });

    // SMART LOGIC: 
    // Kembali ke durasi 24 jam (23h 59m) agar Virtual Account awet.
    const timeDiff = new Date().getTime() - new Date(order.updatedAt).getTime();
    const isRecent = timeDiff < (23 * 60 * 60 * 1000) + (59 * 60 * 1000); // 23h 59m

    if (order.snapToken && isRecent) {
      return res.json({ snapToken: order.snapToken });
    }

    // Jika sudah lama, buat token baru
    const newTransactionId = `${orderId}-${Date.now()}`; // Unique ID for Midtrans

    const parameter = {
      transaction_details: {
        order_id: newTransactionId, // Pakai ID baru agar Midtrans tidak menolak (Duplicate)
        gross_amount: Math.round(order.totalAmount),
      },
      customer_details: { first_name: req.user?.userId },
    };

    const transaction = await snap.createTransaction(parameter);
    
    // Simpan token baru
    await prisma.order.update({
      where: { id: orderId },
      data: { snapToken: transaction.token, snapUrl: transaction.redirect_url }
    });

    res.json({ snapToken: transaction.token });
  } catch (error) {
    console.error("Regenerate Token Error:", error);
    res.status(500).json({ message: 'Failed to regenerate token' });
  }
};

export const handleMidtransWebhook = async (req: Request, res: Response) => {
  try {
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

    await prisma.order.update({
      where: { id: orderId },
      data: { status: orderStatus },
    });

    res.status(200).json({ message: 'Webhook received', status: orderStatus });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error });
  }
};