import makeWASocket, { 
  DisconnectReason, 
  useMultiFileAuthState, 
  fetchLatestBaileysVersion 
} from '@whiskeysockets/baileys';
import pino from 'pino';
import fs from 'fs';
import os from 'os'; // Built-in OS module
import { prisma } from '../lib/prisma';

const AUTH_DIR = './wa_auth';

class WhatsAppService {
  private sock: any;
  private qr: string = '';
  private status: 'CONNECTING' | 'CONNECTED' | 'DISCONNECTED' = 'DISCONNECTED';
  private io: any;

  constructor() {
    if (!fs.existsSync(AUTH_DIR)) {
      fs.mkdirSync(AUTH_DIR, { recursive: true });
    }
  }

  public setSocketIo(io: any) {
    this.io = io;
  }

  public async connect() {
    const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);
    const { version } = await fetchLatestBaileysVersion();

    this.sock = makeWASocket({
      version,
      printQRInTerminal: true,
      auth: state,
      logger: pino({ level: 'silent' }) as any,
      browser: ['ArfCoder Bot', 'Chrome', '1.0.0'],
    });

    this.sock.ev.on('creds.update', saveCreds);

    this.sock.ev.on('connection.update', (update: any) => {
      const { connection, lastDisconnect, qr } = update;

      if (qr) {
        this.qr = qr;
        this.status = 'DISCONNECTED';
        if (this.io) this.io.emit('wa_qr', { qr });
      }

      if (connection === 'close') {
        const shouldReconnect = (lastDisconnect?.error as any)?.output?.statusCode !== DisconnectReason.loggedOut;
        this.status = 'DISCONNECTED';
        if (shouldReconnect) {
          this.connect();
        } else {
          if (this.io) this.io.emit('wa_status', { status: 'LOGGED_OUT' });
        }
      } else if (connection === 'open') {
        this.status = 'CONNECTED';
        this.qr = '';
        if (this.io) this.io.emit('wa_status', { status: 'CONNECTED' });
      }
    });

    // --- MESSAGE HANDLER ---
    this.sock.ev.on('messages.upsert', async (m: any) => {
      if (m.type !== 'notify') return;
      const msg = m.messages[0];
      if (!msg.message || msg.key.fromMe) return;

      const jid = msg.key.remoteJid!;
      const text = (msg.message.conversation || msg.message.extendedTextMessage?.text || '').trim();
      
      // 1. Identify User
      const phoneNumber = jid.split('@')[0].replace(/^62/, '0'); // Convert 628... to 08...
      // Also try +62 format just in case
      
      const user = await prisma.user.findFirst({
        where: { 
          OR: [
            { phoneNumber: phoneNumber },
            { phoneNumber: jid.split('@')[0] }, // Match 628...
            { phoneNumber: `+${jid.split('@')[0]}` }
          ]
        }
      });

      const isAdmin = user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN';

import { exec } from 'child_process';

// ... inside message handler ...

      // 2. Command: INFO VPS (Admin Only)
      if (text.toUpperCase() === 'INFO VPS') {
        if (!isAdmin) {
          await this.sendMessage(jid, '⛔ Akses Ditolak. Perintah ini hanya untuk Admin.');
          return;
        }
        
        const cpus = os.cpus();
        const load = os.loadavg();
        const totalMem = os.totalmem() / (1024 * 1024 * 1024); // GB
        const freeMem = os.freemem() / (1024 * 1024 * 1024); // GB
        const uptime = os.uptime() / 3600; // Hours

        // Check Ping (Google DNS)
        exec('ping -c 1 8.8.8.8', async (err, stdout, stderr) => {
          let pingTime = 'N/A';
          if (stdout) {
            const match = stdout.match(/time=([\d.]+)\s*ms/);
            if (match) pingTime = match[1] + ' ms';
          }

          const reply = `
🖥️ *STATUS VPS ARFCODER*

*CPU:* ${cpus[0].model} (${cpus.length} Core)
*Load:* ${load[0].toFixed(2)} / ${load[1].toFixed(2)}
*RAM:* ${freeMem.toFixed(2)} GB Free / ${totalMem.toFixed(2)} GB Total
*Uptime:* ${uptime.toFixed(1)} Jam
*OS:* ${os.type()} ${os.release()}
*Ping (Google):* ${pingTime}
          `.trim();
          
          await this.sendMessage(jid, reply);
        });
        return;
      }

      // 3. Command: LIST ORDER
      if (text.toUpperCase() === 'LIST ORDER') {
        if (!user) {
          await this.sendMessage(jid, '❌ Nomor Anda tidak terdaftar di sistem kami.');
          return;
        }

        // Jika Admin -> Show Summary Last 5 orders
        // Jika User -> Show My Last 5 orders
        const whereClause = isAdmin ? {} : { userId: user.id };
        
        const orders = await prisma.order.findMany({
          where: whereClause,
          take: 5,
          orderBy: { createdAt: 'desc' },
          include: { user: true } // Need user name if Admin
        });

        if (orders.length === 0) {
          await this.sendMessage(jid, 'Belum ada pesanan terbaru.');
          return;
        }

        let reply = isAdmin ? '📦 *5 ORDER TERBARU (GLOBAL)*\n\n' : '📦 *5 PESANAN TERAKHIR ANDA*\n\n';
        
        orders.forEach(o => {
          reply += `📄 *${o.invoiceNumber}*
`;
          if(isAdmin) reply += `👤 ${o.user?.name}\n`;
          reply += `💰 Rp ${o.totalAmount.toLocaleString('id-ID')}\n`;
          reply += `STATUS: ${o.status}\n\n`;
        });

        await this.sendMessage(jid, reply);
        return;
      }

      // 4. Command: CEK #INV (Strict)
      // Regex: CEK (space) #INV- (alphanumeric)
      const cekRegex = /^CEK\s+(#?INV-[\w-]+)$/i;
      const match = text.match(cekRegex);

      if (match) {
        const invoiceNumber = match[1].replace('#', ''); // Remove # if present, backend stores "INV-..."
        
        const order = await prisma.order.findUnique({ // Use findUnique for strict match if invoice is unique
          where: { invoiceNumber: invoiceNumber }, // Strict match!
          include: { items: { include: { product: true } }, user: true }
        });

        if (order) {
          // Security: User can only check THEIR order (unless Admin)
          if (!isAdmin && order.userId !== user?.id) {
             // Optional: Allow public check? Usually privacy matters.
             // User requested: "user non admin cuman bisa cek inv diri sendiri"
             if (user) { // If registered user but not owner
                await this.sendMessage(jid, '⛔ Anda tidak memiliki akses ke pesanan ini.');
                return;
             }
             // If guest (not registered), maybe allow minimal info? No, user said "nomor terkait akun".
             await this.sendMessage(jid, '❌ Nomor Anda tidak terdaftar atau bukan pemilik pesanan ini.');
             return;
          }

          const itemsList = order.items.map((i: any) => `- ${i.product.name} (${i.quantity}x)`).join('\n');
          const reply = `
*DETAIL PESANAN*
---------------------------
*Invoice:* ${order.invoiceNumber}
*Tanggal:* ${new Date(order.createdAt).toLocaleDateString('id-ID')}
*Status:* *${order.status}*
*Total:* Rp ${order.totalAmount.toLocaleString('id-ID')}

*Item:*
${itemsList}

*Akses/Info:*
${order.deliveryInfo || '-'}
          `.trim();
          await this.sendMessage(jid, reply);
        } else {
          await this.sendMessage(jid, '❌ Pesanan tidak ditemukan. Periksa nomor invoice.');
        }
        return;
      }
    });
  }

  public getStatus() {
    return { status: this.status, qr: this.qr };
  }

  public async sendMessage(jid: string, content: string) {
    if (this.status !== 'CONNECTED' || !this.sock) return false;
    try {
      await this.sock.sendMessage(jid, { text: content });
      return true;
    } catch (error) {
      console.error('WA Send Message Error:', error);
      return false;
    }
  }

  public async sendOTP(phoneNumber: string, otp: string) {
    if (this.status !== 'CONNECTED' || !this.sock) {
      throw new Error('WhatsApp bot is not connected');
    }

    let formattedPhone = phoneNumber.replace(/\D/g, '');
    if (formattedPhone.startsWith('0')) formattedPhone = '62' + formattedPhone.slice(1);
    if (!formattedPhone.endsWith('@s.whatsapp.net')) formattedPhone += '@s.whatsapp.net';

    try {
      await this.sock.sendMessage(formattedPhone, { 
        text: `*Kode Login Admin*\n\nKode: *${otp}*\n\nJangan berikan kepada siapapun.` 
      });
    } catch (error) {
      throw new Error('Gagal kirim WA');
    }
  }

  public async logout() {
    try {
      if (this.sock) {
        await this.sock.logout();
        this.sock.end(undefined);
      }
    } catch (e) {
      console.error("Logout Error:", e);
    } finally {
      if (fs.existsSync(AUTH_DIR)) {
        fs.rmSync(AUTH_DIR, { recursive: true, force: true });
      }
      this.status = 'DISCONNECTED';
      this.qr = '';
      if (this.io) this.io.emit('wa_status', { status: 'DISCONNECTED' });
    }
    return true;
  }
}

export const waService = new WhatsAppService();
