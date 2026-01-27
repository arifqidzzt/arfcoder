import { Request, Response, NextFunction } from 'express';
import { decryptPayload, verifySecureHeader } from '../utils/security';

export const secureMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const secureHeader = req.headers['x-arf-secure-token'] as string;
  if (!verifySecureHeader(secureHeader)) {
    return res.status(403).json({ message: 'Access Denied: Invalid Security Header' });
  }

  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    if (req.path.includes('midtrans-webhook')) return next();

    // Check V3 Structure (Payload, Signature, Timestamp, Mode)
    if (!req.body.payload || !req.body.signature || !req.body.timestamp || req.body._m === undefined) {
      return res.status(400).json({ message: 'Access Denied: Invalid Payload Structure V3' });
    }

    const decrypted = decryptPayload(req.body);
    if (!decrypted) {
      return res.status(400).json({ message: 'Access Denied: Decryption Failed' });
    }

    req.body = decrypted;
  }

  next();
};
