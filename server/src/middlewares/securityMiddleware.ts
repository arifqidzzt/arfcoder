import { Request, Response, NextFunction } from 'express';
import { decryptPayload, verifySecureHeader } from '../utils/security';

export const secureMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // 1. Check Custom Header
  const secureHeader = req.headers['x-arf-secure-token'] as string;
  if (!verifySecureHeader(secureHeader)) {
    return res.status(403).json({ message: 'Access Denied: Invalid Security Header' });
  }

  // 2. Check Payload
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    // Skip if it's Midtrans Webhook (handled by route exclusion, but safe to check)
    if (req.path.includes('midtrans-webhook')) return next();

    if (!req.body.payload || !req.body.signature) {
      return res.status(400).json({ message: 'Access Denied: Unencrypted Payload' });
    }

    const decrypted = decryptPayload(req.body);
    if (!decrypted) {
      return res.status(400).json({ message: 'Access Denied: Decryption Failed' });
    }

    req.body = decrypted;
  }

  next();
};
