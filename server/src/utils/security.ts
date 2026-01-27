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
    const { payload, signature, timestamp, _m } = body;

    // Strict Validation
    if (!payload || !signature || !timestamp || _m === undefined) {
      throw new Error('Missing secure payload V3 structure');
    }

    const now = Date.now();
    const reqTime = parseInt(timestamp);

    // 1. Time Check (30s Strict)
    if (Math.abs(now - reqTime) > 30 * 1000) {
      throw new Error('Request expired');
    }

    let decryptedString = '';

    if (_m === 0) {
      // MODE 0: Decrypt -> Verify Outer Signature
      // Extract nonce from payload later? No, nonce was separate in V2 but inside payload in V3 client
      // Wait, client logic: aes(json + nonce). Sig = hmac(aes + nonce)
      // Client V3 logic was: aes(jsonString). Sig = hmac(encrypted + nonce). But nonce is inside jsonString?
      // Let's re-read client logic carefully.
      // Client: nonce is inside payloadObj (_n).
      // Client Sig: Hmac(encrypted + nonce). Wait, nonce var is local string. 
      // If nonce is inside encrypted payload, server can't read it BEFORE decrypting to verify signature!
      // This creates a paradox. 
      // To fix: We must decrypt FIRST for Mode 0, then verify signature using the nonce found inside.
      
      const bytes = CryptoJS.AES.decrypt(payload, SECRET_KEY);
      decryptedString = bytes.toString(CryptoJS.enc.Utf8);
      if (!decryptedString) throw new Error('Decryption Failed Mode 0');

      const dataObj = JSON.parse(decryptedString);
      const nonce = dataObj._n;

      // Verify Signature
      const expectedSig = CryptoJS.HmacSHA256(payload + nonce, SECRET_KEY).toString();
      if (expectedSig !== signature) throw new Error('Invalid Signature Mode 0');

    } else if (_m === 1) {
      // MODE 1: Decrypt -> Verify Inner Signature
      const bytes = CryptoJS.AES.decrypt(payload, SECRET_KEY);
      const wrapperStr = bytes.toString(CryptoJS.enc.Utf8);
      if (!wrapperStr) throw new Error('Decryption Failed Mode 1');

      const wrapper = JSON.parse(wrapperStr);
      // wrapper = { data: jsonString, sig: innerSig }
      
      const expectedInnerSig = CryptoJS.HmacSHA256(wrapper.data, SECRET_KEY).toString();
      if (expectedInnerSig !== wrapper.sig) throw new Error('Invalid Inner Signature Mode 1');

      decryptedString = wrapper.data;
    } else {
      throw new Error('Unknown Encryption Mode');
    }

    // Common Logic (Nonce & Junk Cleanup)
    const finalData = JSON.parse(decryptedString);
    
    // Check Nonce
    const nonce = finalData._n;
    if (!nonce || nonceCache.has(nonce)) {
      throw new Error('Replay Attack (Nonce reused or missing)');
    }
    nonceCache.set(nonce, now + 60000);

    // Cleanup Junk
    delete finalData._n;
    delete finalData._j;
    delete finalData._t;

    return finalData;

  } catch (error) {
    console.error("Decryption V3 Error:", error);
    return null;
  }
};

export const verifySecureHeader = (headerValue: string | undefined): boolean => {
  if (!headerValue) return false;
  const [timestamp, hash] = headerValue.split('.');
  if (!timestamp || !hash) return false;
  
  if (Math.abs(Date.now() - parseInt(timestamp)) > 30 * 1000) return false;
  
  const validHash = CryptoJS.SHA256(SECRET_KEY + timestamp).toString();
  return validHash === hash;
};
