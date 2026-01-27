import CryptoJS from 'crypto-js';

const SECRET_KEY = process.env.APP_SECRET_KEY || 'default-secret-key-change-me';
const nonceCache = new Map<string, number>();

// Cleanup cache
setInterval(() => {
  const now = Date.now();
  for (const [key, expiry] of nonceCache.entries()) {
    if (now > expiry) nonceCache.delete(key);
  }
}, 60 * 1000);

export const decryptPayload = (body: any) => {
  try {
    if (!Array.isArray(body) || body.length !== 5) throw new Error('Format Invalid');

    let payload, signature, timestamp;
    const tsCandidateA = body[2];
    const tsCandidateB = body[0];
    const now = Date.now();
    let isEven = false;

    if (!isNaN(parseInt(tsCandidateA)) && Math.abs(now - parseInt(tsCandidateA)) < 60000) {
      isEven = true;
      timestamp = tsCandidateA;
    } else if (!isNaN(parseInt(tsCandidateB)) && Math.abs(now - parseInt(tsCandidateB)) < 60000) {
      isEven = false;
      timestamp = tsCandidateB;
    } else throw new Error('TS Invalid');

    if (isEven) { payload = body[0]; signature = body[1]; } 
    else { payload = body[2]; signature = body[4]; }

    if (Math.abs(now - parseInt(timestamp)) > 30 * 1000) throw new Error('Expired');

    const expectedSig = CryptoJS.HmacSHA256(payload + timestamp, SECRET_KEY).toString();
    if (expectedSig !== signature) throw new Error('Sig Mismatch');

    const l1 = CryptoJS.AES.decrypt(payload, SECRET_KEY).toString(CryptoJS.enc.Utf8);
    const inner = CryptoJS.AES.decrypt(l1, SECRET_KEY).toString(CryptoJS.enc.Utf8);
    const finalData = JSON.parse(inner);

    // Payload Nonce Check
    if (!finalData._n || nonceCache.has(finalData._n)) throw new Error('Replay');
    nonceCache.set(finalData._n, now + 60000);

    delete finalData._n; delete finalData._j; delete finalData._res; delete finalData._ua; delete finalData._tz;
    return finalData;
  } catch (e) { return null; }
};

export const verifySecureHeader = (headerValue: string | undefined): boolean => {
  if (!headerValue) return false;

  try {
    // New Format: TIMESTAMP . HASH . ENCRYPTED_NONCE
    const parts = headerValue.split('.');
    if (parts.length !== 3) return false;

    const [timestamp, hash, encNonce] = parts;
    const now = Date.now();

    // 1. Time Check
    if (Math.abs(now - parseInt(timestamp)) > 30 * 1000) return false;

    // 2. Decrypt Nonce
    const nonceBytes = CryptoJS.AES.decrypt(encNonce, SECRET_KEY);
    const nonceRaw = nonceBytes.toString(CryptoJS.enc.Utf8); // Format: RAND:TIME
    if (!nonceRaw || !nonceRaw.includes(':')) return false;

    const nonceValue = nonceRaw.split(':')[0];

    // 3. Verify Hash (Key + Timestamp + Nonce)
    const validHash = CryptoJS.SHA256(SECRET_KEY + timestamp + nonceValue).toString();
    if (validHash !== hash) return false;

    // 4. Nonce Cache (Used once check)
    if (nonceCache.has(nonceRaw)) return false;
    nonceCache.set(nonceRaw, now + 60000);

    return true;
  } catch (e) { return false; }
};