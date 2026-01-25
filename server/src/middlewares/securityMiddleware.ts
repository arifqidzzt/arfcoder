import { Request, Response, NextFunction } from 'express';
import { decryptPayload, verifySecureHeader } from '../utils/security';

export const secureMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // 1. Check Custom Header
  const secureHeader = req.headers['x-arf-secure-token'] as string;
  
  // DEBUG LOG (REMOVE IN PRODUCTION)
  // console.log(`[SEC] Header: ${secureHeader} | Valid: ${verifySecureHeader(secureHeader)}`);

  if (!verifySecureHeader(secureHeader)) {
    console.error(`[SEC-FAIL] Invalid Header: ${secureHeader}`);
    return res.status(403).json({ message: 'Access Denied: Invalid Security Header' });
  }

  // 2. Check Payload (Only for POST/PUT/PATCH methods that send data)
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    if (!req.body.payload || !req.body.signature) {
      return res.status(400).json({ message: 'Access Denied: Unencrypted Payload' });
    }

    const decrypted = decryptPayload(req.body);
    if (!decrypted) {
      return res.status(400).json({ message: 'Access Denied: Decryption Failed or Invalid Signature' });
    }

    // Replace req.body with decrypted data so controllers don't need to change
    req.body = decrypted;
  }

  next();
};
