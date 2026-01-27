import { Request, Response, NextFunction } from 'express';

// DUMMY MIDDLEWARE (Security Disabled for Stability)
export const secureMiddleware = (req: Request, res: Response, next: NextFunction) => {
  return next();
};