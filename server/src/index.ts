import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

import authRoutes from './routes/authRoutes';
import productRoutes from './routes/productRoutes';
import orderRoutes from './routes/orderRoutes';
import adminRoutes from './routes/adminRoutes';
import { saveMessage } from './services/chatService';
import { handleMidtransWebhook } from './controllers/orderController';
import { prisma } from './lib/prisma';
import { secureMiddleware } from './middlewares/securityMiddleware';

dotenv.config();

const app = express();
const httpServer = createServer(app);
import { waService } from './services/whatsappService';

// --- SECURITY MIDDLEWARES ---
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" } // Allow images to be loaded from other domains if needed
}));

// Trust Proxy (Required for Nginx/VPS to get real user IP)
app.set('trust proxy', 1);

// Rate Limiters
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 500, // Limit each IP to 500 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Terlalu banyak request, coba lagi nanti.' }
});

const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 60, // Limit each IP to 60 login/register attempts per hour
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Terlalu banyak percobaan login/daftar, coba lagi dalam 1 jam.' }
});

// ...
const io = new Server(httpServer, {
  cors: {
    origin: process.env.CLIENT_URL || 'http://localhost:3000',
    methods: ['GET', 'POST'],
  },
});

// Inject IO to WA Service
waService.setSocketIo(io);
waService.connect(); // Start bot on server start

app.use(cors());
// ...
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
// Global API Limiter
app.use('/api', apiLimiter);

// Webhook (NO SECURITY MIDDLEWARE - PUBLIC)
app.post('/api/midtrans-webhook', handleMidtransWebhook);

import userRoutes from './routes/userRoutes';

// Apply Security Middleware to all protected routes
// This ensures that only our Frontend can talk to these APIs
app.use('/api/auth', authLimiter, secureMiddleware, authRoutes);
app.use('/api/user', secureMiddleware, userRoutes);
app.use('/api/products', secureMiddleware, productRoutes);
app.use('/api/orders', secureMiddleware, orderRoutes);
app.use('/api/admin', secureMiddleware, adminRoutes);

app.get('/', (req: Request, res: Response) => {
  res.send('ArfCoder API is running...');
});

// --- UPGRADED SOCKET.IO WITH ANTI-SPAM ---
io.on('connection', (socket) => {
  socket.on('sendMessage', async (data: any) => {
    const { content, senderId, isAdmin } = data;
    
    try {
      if (!isAdmin) {
        // Cek jumlah pesan terakhir yang belum dibalas admin
        const lastMessages = await prisma.message.findMany({
          where: { senderId },
          orderBy: { createdAt: 'desc' },
          take: 11
        });

        const unrepliedCount = lastMessages.findIndex(m => m.isAdmin === true);
        
        // Jika tidak ada balasan admin dalam 10 pesan terakhir
        if (unrepliedCount === -1 && lastMessages.length >= 10) {
          socket.emit('error_message', { message: 'Batas pesan tercapai. Tunggu balasan admin.' });
          return;
        }
      }

      const message = await saveMessage(content, senderId, isAdmin);
      io.emit('receiveMessage', message);
      
      // Update status isRead jika admin yang kirim
      if (isAdmin) {
        await prisma.message.updateMany({
          where: { senderId: data.targetUserId, isAdmin: false },
          data: { isRead: true }
        });
      }
    } catch (error) {
      console.error('Chat Error:', error);
    }
  });
});

const PORT = process.env.PORT || 5000;
httpServer.listen(PORT, () => console.log(`Server running on port ${PORT}`));
