import axios from 'axios';
import { encryptPayload, generateSecureHeader } from './security';
import { useAuthStore } from '@/store/useAuthStore';

// Create custom instance
const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api',
});

// Request Interceptor (ENCRYPTION V5 ULTIMATE ENABLED)
api.interceptors.request.use(
  (config) => {
    // 1. Add Auth Token
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // 2. Add Security Header (Timestamp.Hash)
    config.headers['x-arf-secure-token'] = generateSecureHeader();

    // 3. Encrypt Body into Obfuscated Array
    if (['post', 'put', 'patch'].includes(config.method?.toLowerCase() || '') && config.data) {
      // Skip for File Uploads (FormData)
      if (!(config.data instanceof FormData)) {
        const secureBody = encryptPayload(config.data);
        if (secureBody) {
          config.data = secureBody; // Body now becomes [A, B, C, D, E]
        }
      }
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor (Auto Logout on 401)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export default api;
