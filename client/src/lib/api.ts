import axios from 'axios';
import { useAuthStore } from '@/store/useAuthStore';

// Create custom instance
const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api',
});

// Request Interceptor (NORMAL MODE - No Encryption)
api.interceptors.request.use(
  (config) => {
    // 1. Add Auth Token if exists
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
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
      // useAuthStore.getState().logout();
    }
    return Promise.reject(error);
  }
);

export default api;