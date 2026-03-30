import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { Request, Response, NextFunction } from "express";
import { apiError } from "../core/api-error";
import { env } from "../env";

const JWT_SECRET = env.JWT_SECRET ?? "your_jwt_secret_key";
const SALT_ROUNDS = 10;

export interface JWTPayload {
  userId: string;
  email: string;
}

export const authService = {
  // Hash password
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
  },

  // Compare password
  async comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  },

  // Generate JWT token
  generateToken(payload: JWTPayload): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: "7d" });
  },

  // Verify JWT token
  verifyToken(token: string): JWTPayload {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
  },
};

export const getUserFromJwt = (
  headers: Record<string, string | string[] | undefined>
): JWTPayload | "no-token" | "invalid-token" => {
  const authHeader = headers["authorization"];
  if (!authHeader || Array.isArray(authHeader)) {
    return "no-token";
  }
  const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

  if (!token) {
    return "no-token";
  }

  try {
    const user = authService.verifyToken(token);
    return user;
  } catch (error) {
    return "invalid-token";
  }
};

export function getUser(req: Request): JWTPayload;
export function getUser(
  req: Request,
  param: { isRequired: false }
): JWTPayload | null;
export function getUser(req: Request, param: { isRequired: true }): JWTPayload;

export function getUser(req: Request, param?: { isRequired: boolean }) {
  if (req.user) {
    return req.user;
  }

  // try to fetch again incase of middleware order issues
  const nUser = getUserFromJwt(req.headers);

  if (nUser && nUser !== "no-token" && nUser !== "invalid-token") {
    req.user = nUser;
    return nUser;
  }

  if (param?.isRequired ?? true) {
    throw apiError(401, "Authentication required");
  }
  return null;
}
