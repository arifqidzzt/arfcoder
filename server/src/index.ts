import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';

import authRoutes from './routes/authRoutes';
import productRoutes from './routes/productRoutes';
import orderRoutes from './routes/orderRoutes';
import adminRoutes from './routes/adminRoutes';
import { saveMessage } from './services/chatService';
import { handleMidtransWebhook } from './controllers/orderController';
import { prisma } from './lib/prisma';

dotenv.config();

const app = express();
const httpServer = createServer(app);
import { waService } from './services/whatsappService';

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
app.use(express.json());

app.post('/api/midtrans-webhook', handleMidtransWebhook);

import userRoutes from './routes/userRoutes';

// ...
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes); // New Route
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/admin', adminRoutes);

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
