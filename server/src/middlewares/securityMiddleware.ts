import { Request, Response, NextFunction } from 'express';
import { decryptPayload, verifySecureHeader } from '../utils/security';

export const secureMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const secureHeader = req.headers['x-arf-secure-token'] as string;
  if (!verifySecureHeader(secureHeader)) {
    return res.status(403).json({ message: 'Access Denied: Invalid Security Header' });
  }

  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    if (req.path.includes('midtrans-webhook')) return next();

    // Check V5 Structure (Must be Array length 5)
    if (!Array.isArray(req.body) || req.body.length !== 5) {
      return res.status(400).json({ message: 'Access Denied: Invalid Obfuscated Payload' });
    }

    const decrypted = decryptPayload(req.body);
    if (!decrypted) {
      return res.status(400).json({ message: 'Access Denied: Decryption Failed' });
    }

    req.body = decrypted;
  }

  next();
};
