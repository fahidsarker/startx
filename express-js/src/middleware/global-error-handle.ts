import { Request, Response, NextFunction } from "express";

export const globalErrorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const status = err.statusCode || 500;
  const errorResponse: { message: string; stackTrace?: string } = {
    message: err.message || "Internal Server Error",
  };
  errorResponse["stackTrace"] = err.stack;

  res.status(status).json(errorResponse);
};
