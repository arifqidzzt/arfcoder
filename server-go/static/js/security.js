/**
 * ARFCODER SECURITY PROTOCOL V6 (TOTAL LOCK)
 * Migrated from TypeScript - security.ts
 * 
 * Features:
 * 1. Global Nonce in Header: EVERY request is One-Time Use
 * 2. V5 Array Obfuscation for Body
 */

const SECRET_KEY = 'default-secret-key-change-me'; // Will be replaced at runtime

/**
 * Generate random string
 */
function generateRandom(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

/**
 * Get browser fingerprint for additional security
 */
function getFingerprint() {
    if (typeof window === 'undefined') {
        return { _res: 'server', _ua: 'server', _tz: 'utc' };
    }
    return {
        _res: `${window.screen.width}x${window.screen.height}`,
        _ua: typeof navigator !== 'undefined' ? CryptoJS.MD5(navigator.userAgent).toString() : 'unknown',
        _tz: Intl.DateTimeFormat().resolvedOptions().timeZone
    };
}

/**
 * Encrypt payload with V6 protocol (double AES + HMAC)
 * Returns array format: [payload, signature, timestamp, junk1, junk2] or shuffled
 */
function encryptPayload(data) {
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
            return [payload, signature, timestamp, generateRandom(10), generateRandom(15)];
        } else {
            return [timestamp, generateRandom(10), payload, generateRandom(12), signature];
        }
    } catch (error) {
        console.error("Encryption V6 Failed:", error);
        return null;
    }
}

/**
 * Generate secure header for ALL requests
 * Format: TIMESTAMP.HASH.ENCRYPTED_NONCE
 */
function generateSecureHeader() {
    const timestamp = Date.now().toString();
    const nonce = generateRandom(16);
    
    // Encrypt Nonce for Header
    const encryptedNonce = CryptoJS.AES.encrypt(nonce + ":" + timestamp, SECRET_KEY).toString();
    
    // Hash = SHA256(Key + Timestamp + Nonce)
    const hash = CryptoJS.SHA256(SECRET_KEY + timestamp + nonce).toString();
    
    // Format: TIMESTAMP.HASH.ENCRYPTED_NONCE
    return `${timestamp}.${hash}.${encryptedNonce}`;
}

// Expose functions globally
window.ArfSecurity = {
    encryptPayload,
    generateSecureHeader,
    generateRandom
};
