import makeWASocket, { 
  useMultiFileAuthState, 
  fetchLatestBaileysVersion 
} from '@whiskeysockets/baileys';
import pino from 'pino';
import qrcode from 'qrcode-terminal';

async function startDebugBot() {
  console.log("🛠️ STARTING DEBUG WA BOT...");
  
  const { state, saveCreds } = await useMultiFileAuthState('./wa_auth_debug');
  const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
    version,
    auth: state,
    logger: pino({ level: 'silent' }) as any,
  });

  sock.ev.on('creds.update', saveCreds);

  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;
    
    if (qr) {
      console.log("\nScan QR Code di bawah ini:\n");
      qrcode.generate(qr, { small: true });
    }
    
    if (connection === 'close') {
      console.log('Connection closed. Reconnecting...');
      startDebugBot();
    } else if (connection === 'open') {
      console.log('✅ CONNECTED! Silakan kirim pesan apa saja ke nomor ini.');
    }
  });

  sock.ev.on('messages.upsert', async (m) => {
    if (m.type !== 'notify') return;
    const msg = m.messages[0];
    if (!msg.message || msg.key.fromMe) return;

    console.log("\n📨 PESAN DITERIMA!");
    console.log("---------------------------------------------------");
    console.log("JID (remoteJid):", msg.key.remoteJid);
    console.log("Participant:", msg.key.participant || "(undefined - 1:1 chat)");
    console.log("PushName:", msg.pushName);
    console.log("---------------------------------------------------");
    // console.log(JSON.stringify(msg, null, 2)); // Uncomment for full dump
  });
}

startDebugBot();