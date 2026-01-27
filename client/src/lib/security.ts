import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.NEXT_PUBLIC_APP_SECRET_KEY || 'default-secret-key-change-me';

/**
 * ARFCODER SECURITY PROTOCOL V6 (TOTAL LOCK)
 * 
 * Features:
 * 1. Global Nonce in Header: EVERY request (GET/POST/etc) is One-Time Use.
 * 2. V5 Array Obfuscation for Body.
 */

const generateRandom = (length: number) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

const getFingerprint = () => {
  if (typeof window === 'undefined') return { _res: 'server', _ua: 'server', _tz: 'utc' };
  return {
    _res: `${window.screen.width}x${window.screen.height}`,
    _ua: typeof navigator !== 'undefined' ? CryptoJS.MD5(navigator.userAgent).toString() : 'unknown',
    _tz: Intl.DateTimeFormat().resolvedOptions().timeZone
  };
};

export const encryptPayload = (data: any) => {
  try {
    const timestamp = Date.now().toString();
    const nonce = `${generateRandom(12)}:${timestamp}`;
    
    const innerData = {
      ...data,
      ...getFingerprint(),
      _j: generateRandom(20),
      _n: nonce
    };

    const jsonString = JSON.stringify(innerData);
    const layer1 = CryptoJS.AES.encrypt(jsonString, SECRET_KEY).toString();
    const payload = CryptoJS.AES.encrypt(layer1, SECRET_KEY).toString();
    const signature = CryptoJS.HmacSHA256(payload + timestamp, SECRET_KEY).toString();

    const lastDigit = parseInt(timestamp.slice(-1));
    if (lastDigit % 2 === 0) {
      return [ payload, signature, timestamp, generateRandom(10), generateRandom(15) ];
    } else {
      return [ timestamp, generateRandom(10), payload, generateRandom(12), signature ];
    }
  } catch (error) {
    console.error("Encryption V6 Failed:", error);
    return null;
  }
};

export const generateSecureHeader = () => {
  const timestamp = Date.now().toString();
  const nonce = generateRandom(16);
  // Encrypt Nonce for Header
  const encryptedNonce = CryptoJS.AES.encrypt(nonce + ":" + timestamp, SECRET_KEY).toString();
  // Hash = SHA256(Key + Timestamp + Nonce)
  const hash = CryptoJS.SHA256(SECRET_KEY + timestamp + nonce).toString();
  
  // Format: TIMESTAMP . HASH . ENCRYPTED_NONCE
  return `${timestamp}.${hash}.${encryptedNonce}`;
};