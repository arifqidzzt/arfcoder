import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.NEXT_PUBLIC_APP_SECRET_KEY || 'default-secret-key-change-me';

/**
 * ARFCODER SECURITY PROTOCOL V5 (OBFUSCATED ARRAY)
 * 
 * Fitur:
 * 1. Output bukan JSON Object, tapi Array String [ ... ].
 * 2. Posisi Payload/Signature ditentukan oleh digit terakhir Timestamp.
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
    
    // 1. Prepare Inner Data
    const innerData = {
      ...data,
      ...getFingerprint(),
      _j: generateRandom(20),
      _n: nonce
    };

    // 2. Encrypt (Double Layer)
    const jsonString = JSON.stringify(innerData);
    const layer1 = CryptoJS.AES.encrypt(jsonString, SECRET_KEY).toString();
    const payload = CryptoJS.AES.encrypt(layer1, SECRET_KEY).toString();

    // 3. Signature
    const signature = CryptoJS.HmacSHA256(payload + timestamp, SECRET_KEY).toString();

    // 4. OBFUSCATION (Array Shuffling)
    const lastDigit = parseInt(timestamp.slice(-1));
    const junk1 = generateRandom(10);
    const junk2 = generateRandom(15);

    if (lastDigit % 2 === 0) {
      // Genap: [ PAYLOAD, SIGNATURE, TIMESTAMP, JUNK, JUNK ]
      return [ payload, signature, timestamp, junk1, junk2 ];
    } else {
      // Ganjil: [ TIMESTAMP, JUNK, PAYLOAD, JUNK, SIGNATURE ]
      return [ timestamp, junk1, payload, junk2, signature ];
    }

  } catch (error) {
    console.error("Encryption V5 Failed:", error);
    return null;
  }
};

export const generateSecureHeader = () => {
  const timestamp = Date.now().toString();
  const hash = CryptoJS.SHA256(SECRET_KEY + timestamp).toString();
  return `${timestamp}.${hash}`;
};
