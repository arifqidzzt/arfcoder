import axios from 'axios';
import { encryptPayload, generateSecureHeader } from './security';
import { useAuthStore } from '@/store/useAuthStore';

// Create custom instance
const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api',
});

// Request Interceptor (ENCRYPTION)
api.interceptors.request.use(
  (config) => {
    // 1. Add Auth Token if exists
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // 2. Add Security Header (MANDATORY)
    config.headers['x-arf-secure-token'] = generateSecureHeader();

    // 3. Encrypt Payload for POST/PUT/PATCH
    if (['post', 'put', 'patch'].includes(config.method?.toLowerCase() || '') && config.data) {
      // Skip encryption for FormData (File Uploads)
      if (!(config.data instanceof FormData)) {
        const secureBody = encryptPayload(config.data);
        if (secureBody) {
          config.data = secureBody;
        }
      }
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Optional: Handle Global Errors like 401 Logout
    if (error.response?.status === 401) {
      // useAuthStore.getState().logout(); // Uncomment if auto-logout desired
    }
    return Promise.reject(error);
  }
);

export default api;
