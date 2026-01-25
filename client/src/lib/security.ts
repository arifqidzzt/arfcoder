import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.NEXT_PUBLIC_APP_SECRET_KEY || 'default-secret-key-change-me';

/**
 * ARFCODER SECURITY PROTOCOL V1
 * 
 * Struktur Enkripsi:
 * 1. Payload dienkripsi AES-256 (CBC Mode, PKCS7 Padding).
 * 2. Signature dibuat dengan HMAC-SHA256 dari (EncryptedPayload + Timestamp).
 * 3. Header Auth dibuat dengan hash dinamis.
 */

export const encryptPayload = (data: any) => {
  try {
    const jsonString = JSON.stringify(data);
    const timestamp = Date.now().toString();

    // 1. Encrypt Data (AES)
    const encrypted = CryptoJS.AES.encrypt(jsonString, SECRET_KEY).toString();

    // 2. Generate Signature (HMAC)
    // Signature = HMAC(payload + timestamp, key)
    const signature = CryptoJS.HmacSHA256(encrypted + timestamp, SECRET_KEY).toString();

    return {
      payload: encrypted,
      timestamp: timestamp,
      signature: signature
    };
  } catch (error) {
    console.error("Encryption Failed:", error);
    return null;
  }
};

export const generateSecureHeader = () => {
  const timestamp = Date.now().toString();
  // Header Token = SHA256(Key + Timestamp)
  // Server nanti cek: Apakah Hash(Key + HeaderTimestamp) == HeaderToken?
  // Tapi simple-nya kita kirim timestamp di header juga biar server bisa verifikasi.
  
  // Custom Header Format: "Timestamp.Hash"
  const hash = CryptoJS.SHA256(SECRET_KEY + timestamp).toString();
  return `${timestamp}.${hash}`;
};
