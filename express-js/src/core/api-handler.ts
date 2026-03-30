import { Request, Response, NextFunction } from "express";
import { Res } from "./response";
import { defaultPageLimit } from "../constants";

export type CKExpressHandler = (
  req: Request,
  res: Response
) => Promise<Res> | Res;

export function apiHandler(fn: CKExpressHandler) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const response = await fn(req, res);
      return response.handle(req, res);
    } catch (err) {
      console.error("API Handler Error:", err);
      next(err);
    }
  };
}

export const queryParams = (req: Request) => {
  let limit = Number(req.query.limit ?? defaultPageLimit);
  if (isNaN(limit) || limit <= 0) {
    limit = defaultPageLimit;
  }

  let offset = Number(req.query.offset ?? 0);
  if (isNaN(offset) || offset < 0) {
    offset = 0;
  }

  let search = req.query.search;
  if (typeof search !== "string") {
    search = undefined;
  }

  return { limit, offset, search };
};
