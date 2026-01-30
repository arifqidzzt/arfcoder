import makeWASocket, { 
  DisconnectReason, 
  useMultiFileAuthState, 
  fetchLatestBaileysVersion 
} from '@whiskeysockets/baileys';
import pino from 'pino';
import fs from 'fs';

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
      printQRInTerminal: true, // Also print in terminal for debug
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
          // Logged out
          if (this.io) this.io.emit('wa_status', { status: 'LOGGED_OUT' });
        }
      } else if (connection === 'open') {
        console.log('WA Connected!');
        this.status = 'CONNECTED';
        this.qr = ''; // Clear QR
        if (this.io) this.io.emit('wa_status', { status: 'CONNECTED' });
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

    // Format phone number robustly
    let formattedPhone = phoneNumber.replace(/\D/g, ''); // Hapus semua karakter non-angka
    
    // Ganti 0 di depan dengan 62
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62' + formattedPhone.slice(1);
    }
    
    // Jika user ngetik 628..., biarkan.
    
    // Tambahkan suffix wajib Baileys
    if (!formattedPhone.endsWith('@s.whatsapp.net')) {
      formattedPhone += '@s.whatsapp.net';
    }

    console.log(`Sending WA OTP to: ${formattedPhone}`); // Debug Log

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
      // Force delete auth folder
      if (fs.existsSync(AUTH_DIR)) {
        fs.rmSync(AUTH_DIR, { recursive: true, force: true });
        console.log("WA Auth folder deleted.");
      }
      this.status = 'DISCONNECTED';
      this.qr = '';
      if (this.io) this.io.emit('wa_status', { status: 'DISCONNECTED' });
      // Don't auto connect immediately, let user click start
    }
    return true;
  }
}

export const waService = new WhatsAppService();
