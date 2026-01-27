import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.APP_SECRET_KEY || 'default-secret-key-change-me';
const nonceCache = new Map<string, number>();

setInterval(() => {
  const now = Date.now();
  for (const [key, expiry] of nonceCache.entries()) {
    if (now > expiry) nonceCache.delete(key);
  }
}, 60 * 1000);

export const decryptPayload = (body: any) => {
  try {
    // Expecting Array [ ... ]
    if (!Array.isArray(body) || body.length !== 5) {
      throw new Error('Invalid Payload Format (Not Array 5)');
    }

    let payload, signature, timestamp;

    // DE-OBFUSCATION LOGIC
    // Kita cari timestamp dulu untuk tahu polanya (atau coba parsing)
    // Cara aman: Cek elemen mana yang angka epoch valid?
    // Tapi karena kita tahu logikanya:
    
    // Cek elemen ke-2 (Index 2) -> Jika Timestamp, berarti Ganjil.
    // Cek elemen ke-2 (Index 2) -> Jika Timestamp, pola [ T, J, P, J, S ] (Salah, index 0 timestamp)
    
    // Mari ikuti logika client:
    // Genap: [ P, S, T, J, J ] (Index: 0, 1, 2, 3, 4) -> Timestamp di Index 2
    // Ganjil: [ T, J, P, J, S ] (Index: 0, 1, 2, 3, 4) -> Timestamp di Index 0

    const tsCandidateA = body[2]; // Genap Candidate
    const tsCandidateB = body[0]; // Ganjil Candidate

    // Cek mana yang angka valid dan mendekati waktu sekarang
    const now = Date.now();
    let isEven = false;

    if (!isNaN(parseInt(tsCandidateA)) && Math.abs(now - parseInt(tsCandidateA)) < 60000) {
      isEven = true;
      timestamp = tsCandidateA;
    } else if (!isNaN(parseInt(tsCandidateB)) && Math.abs(now - parseInt(tsCandidateB)) < 60000) {
      isEven = false;
      timestamp = tsCandidateB;
    } else {
      throw new Error('Timestamp not found or expired in Array');
    }

    if (isEven) {
      // [ P, S, T, J, J ]
      payload = body[0];
      signature = body[1];
    } else {
      // [ T, J, P, J, S ]
      payload = body[2];
      signature = body[4];
    }

    // 1. Time Check
    if (Math.abs(now - parseInt(timestamp)) > 30 * 1000) throw new Error('Request expired');

    // 2. Signature Check
    const expectedSig = CryptoJS.HmacSHA256(payload + timestamp, SECRET_KEY).toString();
    if (expectedSig !== signature) throw new Error('Invalid Signature');

    // 3. Decrypt
    const layer1Bytes = CryptoJS.AES.decrypt(payload, SECRET_KEY);
    const layer1Str = layer1Bytes.toString(CryptoJS.enc.Utf8);
    if (!layer1Str) throw new Error('Decryption Failed L2');

    const innerBytes = CryptoJS.AES.decrypt(layer1Str, SECRET_KEY);
    const innerStr = innerBytes.toString(CryptoJS.enc.Utf8);
    if (!innerStr) throw new Error('Decryption Failed L1');

    const finalData = JSON.parse(innerStr);

    // 4. Nonce Check
    const nonce = finalData._n;
    if (!nonce || nonceCache.has(nonce)) throw new Error('Replay Attack');
    nonceCache.set(nonce, now + 60000);

    // Cleanup
    delete finalData._n;
    delete finalData._j;
    delete finalData._res;
    delete finalData._ua;
    delete finalData._tz;

    return finalData;

  } catch (error) {
    console.error("Decryption V5 Error:", error);
    return null;
  }
};

export const verifySecureHeader = (headerValue: string | undefined): boolean => {
  if (!headerValue) return false;
  const [timestamp, hash] = headerValue.split('.');
  if (!timestamp || !hash) return false;
  if (Math.abs(Date.now() - parseInt(timestamp)) > 30 * 1000) return false;
  return CryptoJS.SHA256(SECRET_KEY + timestamp).toString() === hash;
};
