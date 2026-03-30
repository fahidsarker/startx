import { ApiData, NeverPromise } from "../types/core-types";
import {
  ErrorStatusCodes,
  StatusCodes,
  SuccessStatusCodes,
} from "../types/status-codes";
import { Request, Response } from "express";
import { apiError } from "./api-error";

type Headers = Record<string, string>;

function create(fn: (req: Request, res: Response) => void) {
  return new Res(fn);
}
const applyHeaders = (res: Response, headers?: Headers) => {
  if (!headers) return;
  for (const key in headers) {
    res.setHeader(key, headers[key]);
  }
};

export class Res {
  readonly handle: (req: Request, res: Response) => void;

  constructor(handle: (req: Request, res: Response) => void) {
    this.handle = handle;
  }

  static json<T extends ApiData>(
    data: NeverPromise<T>,
    status?: StatusCodes,
    headers?: Headers
  ) {
    return create((req, res) => {
      applyHeaders(res, headers);
      res.status(status ?? 200).send(data);
    });
  }

  static html(
    html: `${string}<!DOCTYPE html>${string}</html>${string}`,
    status?: StatusCodes,
    headers?: Headers
  ) {
    return create((req, res) => {
      applyHeaders(res, headers);
      res.status(status ?? 200).send(html);
    });
  }

  static redirect(url: string) {
    return create((req, res) => {
      res.redirect(url);
    });
  }

  static success(status: SuccessStatusCodes = 200) {
    return new Res((req, res) => res.status(status).send());
  }

  static message(message: string) {
    return Res.json({ message });
  }

  static none() {
    return new Res(() => {});
  }

  static error(err: string, code: ErrorStatusCodes = 500) {
    return new Res(() => {
      throw apiError(code, err);
    });
  }
}
