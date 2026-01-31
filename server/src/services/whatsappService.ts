import makeWASocket, { 
  DisconnectReason, 
  useMultiFileAuthState, 
  fetchLatestBaileysVersion 
} from '@whiskeysockets/baileys';
import pino from 'pino';
import fs from 'fs';
import os from 'os';
import { exec } from 'child_process';
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
      if (!msg.message) return;

      const text = (msg.message.conversation || msg.message.extendedTextMessage?.text || '').trim();
      
      // Infinite Loop Protection
      if (msg.key.fromMe && !text.toUpperCase().startsWith('INFO') && !text.toUpperCase().startsWith('CEK') && !text.toUpperCase().startsWith('LIST')) {
         return;
      }

      const jid = msg.key.participant || msg.key.remoteJid!;
      const rawNumber = jid.split('@')[0];
      const phoneNumber = rawNumber.replace(/^62/, '0');
      
      const user = await prisma.user.findFirst({
        where: { 
          OR: [
            { phoneNumber: phoneNumber },
            { phoneNumber: rawNumber },
            { phoneNumber: `+${rawNumber}` },
            { phoneNumber: phoneNumber.replace(/^0/, '62') }
          ]
        }
      });

      const isAdmin = user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN';

      // 2. Command: INFO VPS
      if (text.toUpperCase() === 'INFO VPS') {
        if (!isAdmin) {
          const debugInfo = user ? `Login: ${user.name} (${user.role})` : `Nomor ${rawNumber} tidak terdaftar.`;
          await this.sendMessage(msg.key.remoteJid!, `⚠️ SECURITY CHECK FAILED\n\nBot tidak mengenali Anda sebagai Admin.\n\n${debugInfo}\n\nSolusi: Masukkan nomor ${rawNumber} di Profile Admin.`);
          return;
        }
        
        await this.sendMessage(msg.key.remoteJid!, '⏳ Mengumpulkan data server... (Estimasi 5-10 detik)');

        const cpus = os.cpus();
        const totalMem = os.totalmem() / (1024 * 1024 * 1024);
        const freeMem = os.freemem() / (1024 * 1024 * 1024);
        const uptime = os.uptime() / 3600;

        const execPromise = (cmd: string): Promise<string> => new Promise((resolve) => {
          exec(cmd, (err, stdout) => resolve(stdout ? stdout.trim() : 'N/A'));
        });

        try {
          const [disk, osDistro, ipInfoStr, speedTestOut] = await Promise.all([
            execPromise(`df -h / | tail -1 | awk '{print $3 " / " $2 " (" $5 ")"}'`), 
            execPromise(`grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'`), 
            execPromise(`curl -s ipinfo.io/json`), 
            execPromise(`speedtest-cli`) // Tanpa --simple sesuai request
          ]);

          const ipInfo = JSON.parse(ipInfoStr === 'N/A' ? '{}' : ipInfoStr);
          
          // Regex for: "Download: 972.78 Mbit/s"
          const dlMatch = speedTestOut.match(/Download:\s+([\d.]+)/);
          const ulMatch = speedTestOut.match(/Upload:\s+([\d.]+)/);
          const dlSpeed = dlMatch ? dlMatch[1] + ' Mbps' : 'N/A';
          const ulSpeed = ulMatch ? ulMatch[1] + ' Mbps' : 'N/A';

          const reply = `
🚀 *ARFCODER SERVER STATUS*
---------------------------
💻 *SISTEM OPERASI*
• Distro: ${osDistro === 'N/A' ? os.type() : osDistro}
• Kernel: ${os.release()}
• Uptime: ${uptime.toFixed(1)} Jam
• Node.js: ${process.version}

🌍 *JARINGAN & LOKASI*
• IP: ${ipInfo.ip || 'Hidden'}
• Lokasi: ${ipInfo.city || '?'}, ${ipInfo.country || '?'}
• ISP: ${ipInfo.org || '?'}
• Speed (DL): ${dlSpeed}
• Speed (UL): ${ulSpeed}

🧠 *RESOURCE*
• CPU: ${cpus[0].model} (${cpus.length} Core)
• RAM: ${freeMem.toFixed(2)}GB Free / ${totalMem.toFixed(2)}GB Total
• Disk: ${disk}

---------------------------
Bot Active | ${new Date().toLocaleString('id-ID')}
          `.trim();
          
          await this.sendMessage(msg.key.remoteJid!, reply);
        } catch (e) {
          await this.sendMessage(msg.key.remoteJid!, 'Gagal mengambil data lengkap.');
        }
        return;
      }

      // 3. Command: LIST ORDER
      if (text.toUpperCase() === 'LIST ORDER') {
        if (!user) {
          await this.sendMessage(msg.key.remoteJid!, '❌ Nomor Anda tidak terdaftar.');
          return;
        }
        const whereClause = isAdmin ? {} : { userId: user.id };
        const orders = await prisma.order.findMany({
          where: whereClause,
          take: 5,
          orderBy: { createdAt: 'desc' },
          include: { user: true }
        });
        if (orders.length === 0) {
          await this.sendMessage(msg.key.remoteJid!, 'Belum ada pesanan.');
          return;
        }
        let reply = isAdmin ? '📦 *5 ORDER TERBARU (GLOBAL)*\n\n' : '📦 *5 PESANAN TERAKHIR ANDA*\n\n';
        orders.forEach(o => {
          reply += `📄 *${o.invoiceNumber}*\n`;
          if(isAdmin) reply += `👤 ${o.user?.name}\n`;
          reply += `💰 Rp ${o.totalAmount.toLocaleString('id-ID')}\n`;
          reply += `STATUS: ${o.status}\n\n`;
        });
        await this.sendMessage(msg.key.remoteJid!, reply);
        return;
      }

      // 4. Command: CEK #INV
      const cekRegex = /^CEK\s+(#?INV-[\w-]+)$/i;
      const match = text.match(cekRegex);
      if (match) {
        const invoiceNumber = match[1].replace('#', '');
        const order = await prisma.order.findUnique({
          where: { invoiceNumber: invoiceNumber },
          include: { items: { include: { product: true } }, user: true }
        });
        if (order) {
          if (!isAdmin && order.userId !== user?.id) {
             await this.sendMessage(msg.key.remoteJid!, '⛔ Akses Ditolak. Bukan pesanan Anda.');
             return;
          }
          const itemsList = order.items.map((i: any) => `- ${i.product.name} (${i.quantity}x)`).join('\n');
          const reply = `
*DETAIL PESANAN*
---------------------------
*Invoice:* ${order.invoiceNumber}
*Status:* *${order.status}*
*Total:* Rp ${order.totalAmount.toLocaleString('id-ID')}

*Item:*
${itemsList}

*Info:* ${order.deliveryInfo || '-'}
          `.trim();
          await this.sendMessage(msg.key.remoteJid!, reply);
        } else {
          await this.sendMessage(msg.key.remoteJid!, '❌ Pesanan tidak ditemukan.');
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
    } catch (error) { return false; }
  }

  public async sendOTP(phoneNumber: string, otp: string) {
    if (this.status !== 'CONNECTED' || !this.sock) throw new Error('WhatsApp bot disconnected');
    let formattedPhone = phoneNumber.replace(/\D/g, '');
    if (formattedPhone.startsWith('0')) formattedPhone = '62' + formattedPhone.slice(1);
    if (!formattedPhone.endsWith('@s.whatsapp.net')) formattedPhone += '@s.whatsapp.net';
    try {
      await this.sock.sendMessage(formattedPhone, { 
        text: `*Kode Login Admin*\n\nKode: *${otp}*\n\nJangan berikan kepada siapapun.` 
      });
    } catch (error) { throw new Error('Gagal kirim WA'); }
  }

  public async logout() {
    try {
      if (this.sock) {
        await this.sock.logout();
        this.sock.end(undefined);
      }
    } catch (e) { } finally {
      if (fs.existsSync(AUTH_DIR)) fs.rmSync(AUTH_DIR, { recursive: true, force: true });
      this.status = 'DISCONNECTED';
      this.qr = '';
      if (this.io) this.io.emit('wa_status', { status: 'DISCONNECTED' });
    }
    return true;
  }
}

export const waService = new WhatsAppService();