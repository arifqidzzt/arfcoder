import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.NEXT_PUBLIC_APP_SECRET_KEY || 'default-secret-key-change-me';

/**
 * ARFCODER SECURITY PROTOCOL V3 (POLYMORPHIC)
 * 
 * Fitur Ultimate:
 * 1. Polymorphic Encryption: Struktur berubah acak tiap request.
 * 2. Mode 0: Standard (Payload AES + Signature HMAC).
 * 3. Mode 1: Inverted (Signature masuk ke dalam AES, lalu di-Hash lagi luarnya).
 * 4. Junk Data Wajib & Random Length.
 */

const generateRandom = (length: number) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

export const encryptPayload = (data: any) => {
  try {
    const timestamp = Date.now().toString();
    const nonce = `${generateRandom(16)}:${timestamp}`;
    
    // Pilih Mode Acak (0 atau 1)
    const mode = Math.floor(Math.random() * 2);

    // Siapkan Data + Junk
    const payloadObj = {
      ...data,
      _j: generateRandom(Math.floor(Math.random() * 50) + 20), // Junk 20-70 chars
      _n: nonce,
      _t: timestamp
    };

    const jsonString = JSON.stringify(payloadObj);
    let finalPayload = '';
    let finalSignature = '';

    if (mode === 0) {
      // MODE 0: Standard Encrypt -> Sign
      const encrypted = CryptoJS.AES.encrypt(jsonString, SECRET_KEY).toString();
      const signature = CryptoJS.HmacSHA256(encrypted + nonce, SECRET_KEY).toString();
      
      finalPayload = encrypted;
      finalSignature = signature;
    } else {
      // MODE 1: Sign Inside -> Encrypt Everything
      // Kita buat signature internal dulu
      const innerSig = CryptoJS.HmacSHA256(jsonString, SECRET_KEY).toString();
      const wrappedObj = { data: jsonString, sig: innerSig };
      
      // Encrypt bungkusan itu
      finalPayload = CryptoJS.AES.encrypt(JSON.stringify(wrappedObj), SECRET_KEY).toString();
      // Buat fake signature di luar biar format tetap konsisten (decoy)
      finalSignature = CryptoJS.HmacSHA256("decoy" + timestamp, SECRET_KEY).toString();
    }

    return {
      payload: finalPayload,
      signature: finalSignature,
      timestamp: timestamp,
      _m: mode // Kirim mode ke server
    };
  } catch (error) {
    console.error("Encryption V3 Failed:", error);
    return null;
  }
};

export const generateSecureHeader = () => {
  const timestamp = Date.now().toString();
  const hash = CryptoJS.SHA256(SECRET_KEY + timestamp).toString();
  return `${timestamp}.${hash}`;
};
