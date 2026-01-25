import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.APP_SECRET_KEY || 'default-secret-key-change-me';

export const decryptPayload = (body: any) => {
  try {
    const { payload, signature, timestamp } = body;

    if (!payload || !signature || !timestamp) {
      throw new Error('Missing secure payload structure');
    }

    // 1. Verify Timestamp (Max age: 2 minutes to prevent Replay Attack)
    const now = Date.now();
    const reqTime = parseInt(timestamp);
    if (Math.abs(now - reqTime) > 2 * 60 * 1000) {
      throw new Error('Request expired (Replay Attack Detected)');
    }

    // 2. Verify Signature
    const computedSignature = CryptoJS.HmacSHA256(payload + timestamp, SECRET_KEY).toString();
    if (computedSignature !== signature) {
      throw new Error('Invalid Signature (Data Tampered)');
    }

    // 3. Decrypt Payload
    const bytes = CryptoJS.AES.decrypt(payload, SECRET_KEY);
    const decryptedData = JSON.parse(bytes.toString(CryptoJS.enc.Utf8));

    return decryptedData;
  } catch (error) {
    console.error("Decryption Error:", error);
    return null;
  }
};

export const verifySecureHeader = (headerValue: string | undefined): boolean => {
  if (!headerValue) return false;

  const [timestamp, hash] = headerValue.split('.');
  if (!timestamp || !hash) return false;

  // Verify Timestamp Age (2 mins)
  const now = Date.now();
  if (Math.abs(now - parseInt(timestamp)) > 2 * 60 * 1000) return false;

  // Verify Hash
  const validHash = CryptoJS.SHA256(SECRET_KEY + timestamp).toString();
  return validHash === hash;
};
