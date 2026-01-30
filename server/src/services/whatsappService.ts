import makeWASocket, { 
  DisconnectReason, 
  useMultiFileAuthState, 
  fetchLatestBaileysVersion 
} from '@whiskeysockets/baileys';
import pino from 'pino';
import fs from 'fs';
import { prisma } from '../lib/prisma'; // Import at top

const AUTH_DIR = './wa_auth';

// Singleton class for WhatsApp
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
        console.log('WA QR Code Generated');
        if (this.io) this.io.emit('wa_qr', { qr });
      }

      if (connection === 'close') {
        const shouldReconnect = (lastDisconnect?.error as any)?.output?.statusCode !== DisconnectReason.loggedOut;
        console.log('WA Connection closed. Reconnecting:', shouldReconnect);
        this.status = 'DISCONNECTED';
        if (shouldReconnect) {
          this.connect();
        } else {
          if (this.io) this.io.emit('wa_status', { status: 'LOGGED_OUT' });
        }
      } else if (connection === 'open') {
        console.log('WA Connected!');
        this.status = 'CONNECTED';
        this.qr = '';
        if (this.io) this.io.emit('wa_status', { status: 'CONNECTED' });
      }
    });

    // LISTENER PESAN MASUK
    this.sock.ev.on('messages.upsert', async (m: any) => {
      if (m.type !== 'notify') return;
      
      const msg = m.messages[0];
      if (!msg.message || msg.key.fromMe) return;

      const jid = msg.key.remoteJid;
      const text = msg.message.conversation || msg.message.extendedTextMessage?.text || '';

      // LOGIC CEK STATUS ORDER
      // Format: "CEK #INV-xxx"
      if (text.toUpperCase().startsWith('CEK #')) {
        const invoiceNumber = text.split('#')[1]?.trim();
        if (invoiceNumber) {
          try {
            const order = await prisma.order.findFirst({
              where: { invoiceNumber: { contains: invoiceNumber, mode: 'insensitive' } },
              include: { items: { include: { product: true } } }
            });

            if (order) {
              const itemsList = order.items.map((i: any) => `- ${i.product.name} (${i.quantity}x)`).join('\n');
              const reply = `*STATUS PESANAN*\nInvoice: ${order.invoiceNumber}\nStatus: *${order.status}*\nTotal: Rp ${order.totalAmount.toLocaleString('id-ID')}\n\nItem:\n${itemsList}\n\nTerima kasih!`;
              await this.sendMessage(jid, reply);
            } else {
              await this.sendMessage(jid, 'Pesanan tidak ditemukan. Pastikan nomor invoice benar.');
            }
          } catch (error) {
            console.error('WA Auto Reply Error:', error);
          }
        }
      }
    });
  }

  public getStatus() {
    return { status: this.status, qr: this.qr };
  }

  public async sendMessage(jid: string, content: string) {
    if (this.status !== 'CONNECTED' || !this.sock) {
      console.warn('WA Bot not connected, skipping message.');
      return false;
    }
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
    
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62' + formattedPhone.slice(1);
    }
    
    if (!formattedPhone.endsWith('@s.whatsapp.net')) {
      formattedPhone += '@s.whatsapp.net';
    }

    console.log(`Sending WA OTP to: ${formattedPhone}`);

    try {
      await this.sock.sendMessage(formattedPhone, { 
        text: `*Kode Verifikasi ArfCoder*\n\nKode Anda: *${otp}*\n\nJangan berikan kode ini kepada siapapun.` 
      });
    } catch (error) {
      console.error('WA Send Error:', error);
      throw new Error('Gagal mengirim pesan WA');
    }
  }

  public async logout() {
    try {
      if (this.sock) {
        await this.sock.logout();
        this.sock.end(undefined);
      }
    } catch (e) {
      console.error("Logout Error (Ignored):", e);
    } finally {
      if (fs.existsSync(AUTH_DIR)) {
        fs.rmSync(AUTH_DIR, { recursive: true, force: true });
        console.log("WA Auth folder deleted.");
      }
      this.status = 'DISCONNECTED';
      this.qr = '';
      if (this.io) this.io.emit('wa_status', { status: 'DISCONNECTED' });
    }
    return true;
  }
}

export const waService = new WhatsAppService();