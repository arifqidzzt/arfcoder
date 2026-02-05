/**
 * API Module with Encryption
 * Port of security.ts from TypeScript frontend
 */

const API_URL = '/api';
const SECRET_KEY = window.APP_SECRET_KEY || '';

// ========================================
// CRYPTO HELPERS (Using Web Crypto API + CryptoJS CDN)
// ========================================

// Load CryptoJS from CDN
const cryptoScript = document.createElement('script');
cryptoScript.src = 'https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.2.0/crypto-js.min.js';
document.head.appendChild(cryptoScript);

// Wait for CryptoJS to load
function waitForCrypto() {
    return new Promise((resolve) => {
        if (window.CryptoJS) {
            resolve(window.CryptoJS);
        } else {
            cryptoScript.onload = () => resolve(window.CryptoJS);
        }
    });
}

/**
 * Generate random alphanumeric string
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
 * Get browser fingerprint data
 */
function getFingerprint() {
    return {
        _res: `${window.screen.width}x${window.screen.height}`,
        _ua: navigator.userAgent.slice(0, 50),
        _tz: Intl.DateTimeFormat().resolvedOptions().timeZone
    };
}

/**
 * Encrypt payload for API requests
 */
async function encryptPayload(data) {
    const CryptoJS = await waitForCrypto();
    const timestamp = Date.now();
    const nonce = generateRandom(16);

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

    const lastDigit = timestamp % 10;
    if (lastDigit % 2 === 0) {
        return [payload, signature, String(timestamp), generateRandom(10), generateRandom(15)];
    } else {
        return [String(timestamp), generateRandom(10), payload, generateRandom(12), signature];
    }
}

/**
 * Generate secure header for API requests
 */
async function generateSecureHeader() {
    const CryptoJS = await waitForCrypto();
    const timestamp = Date.now().toString();
    const nonce = generateRandom(16);
    const encryptedNonce = CryptoJS.AES.encrypt(nonce + ':' + timestamp, SECRET_KEY).toString();
    const hash = CryptoJS.SHA256(SECRET_KEY + timestamp + nonce).toString();
    return `${timestamp}.${hash}.${encryptedNonce}`;
}

// ========================================
// API CLIENT
// ========================================

/**
 * Get auth token from localStorage
 */
function getAuthToken() {
    try {
        const authStorage = localStorage.getItem('auth-storage');
        if (authStorage) {
            const parsed = JSON.parse(authStorage);
            return parsed.state?.token || null;
        }
    } catch (e) {
        console.error('Error getting auth token:', e);
    }
    return null;
}

/**
 * Main API fetch wrapper with encryption
 */
async function apiFetch(endpoint, options = {}) {
    const url = `${API_URL}${endpoint}`;
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };

    // Add auth token
    const token = getAuthToken();
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    // Add security header
    headers['x-arf-secure-token'] = await generateSecureHeader();

    // Encrypt body for POST/PUT/PATCH
    if (['POST', 'PUT', 'PATCH'].includes(options.method?.toUpperCase()) && options.body) {
        if (!(options.body instanceof FormData)) {
            const encryptedBody = await encryptPayload(options.body);
            options.body = JSON.stringify(encryptedBody);
        }
    } else if (options.body && typeof options.body === 'object') {
        options.body = JSON.stringify(options.body);
    }

    const response = await fetch(url, {
        ...options,
        headers
    });

    // Handle 401 - Unauthorized
    if (response.status === 401) {
        // Clear auth state
        localStorage.removeItem('auth-storage');
        window.location.href = '/login';
        throw new Error('Unauthorized');
    }

    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.error || data.message || 'Request failed');
    }

    return data;
}

// ========================================
// API METHODS
// ========================================

const api = {
    // GET request
    get: (endpoint) => apiFetch(endpoint, { method: 'GET' }),

    // POST request
    post: (endpoint, body) => apiFetch(endpoint, { method: 'POST', body }),

    // PUT request
    put: (endpoint, body) => apiFetch(endpoint, { method: 'PUT', body }),

    // PATCH request
    patch: (endpoint, body) => apiFetch(endpoint, { method: 'PATCH', body }),

    // DELETE request
    delete: (endpoint) => apiFetch(endpoint, { method: 'DELETE' }),

    // File upload (FormData, skip encryption)
    upload: async (endpoint, formData) => {
        const url = `${API_URL}${endpoint}`;
        const headers = {};

        const token = getAuthToken();
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        headers['x-arf-secure-token'] = await generateSecureHeader();

        const response = await fetch(url, {
            method: 'POST',
            headers,
            body: formData
        });

        if (response.status === 401) {
            localStorage.removeItem('auth-storage');
            window.location.href = '/login';
            throw new Error('Unauthorized');
        }

        return response.json();
    }
};

// Export for global use
window.api = api;
window.generateSecureHeader = generateSecureHeader;
window.encryptPayload = encryptPayload;
