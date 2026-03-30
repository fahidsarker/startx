import { Request, Response, NextFunction } from "express";
import { authService, getUserFromJwt, JWTPayload } from "../services/auth";

// Extend Request interface to include user
declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload;
    }
  }
}

export const authRequired = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (req.user) {
    return next();
  }
  const user = getUserFromJwt(req.headers);
  if (user === "no-token") {
    return res.status(401).json({ error: "Access token required" });
  }
  if (user === "invalid-token") {
    return res.status(403).json({ error: "Invalid or expired token" });
  }
  req.user = user;
  next();
};
