import { env } from "../env";

import fs from "fs";
import path from "path";
import { Request } from "express";
import { apiError } from "../core/api-error";
import { getUser } from "./auth";

const basePath = env.FILE_STORAGE_PATH;
const uploadBasePath = path.join(basePath, "uploads");

const dirFromPaths = (...paths: string[]) => {
  const dirPath = path.join(...paths);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
  return dirPath;
};

const buckets = {
  profilePhotos: (p: { userId: string }) =>
    dirFromPaths(uploadBasePath, "profile_photos", p.userId),
  /** Thread or message attachments under a parent resource (e.g. conversation id). */
  messageAttachments: (p: { resourceId: string }) =>
    dirFromPaths(uploadBasePath, "message_attachments", p.resourceId),
  resourceAttachments: (p: { resourceId: string }) =>
    dirFromPaths(uploadBasePath, "resource_attachments", p.resourceId),
};

const uploadStorageFromReq = (req: Request) => {
  const userId = getUser(req).userId;
  const path = req.originalUrl;
  if (path.startsWith("/api/profile")) {
    return buckets.profilePhotos({ userId });
  } else if (path.startsWith("/api/uploads/resource/")) {
    const resourceId = req.params.resourceId;
    if (!resourceId) {
      throw new Error("Resource ID not found in request parameters");
    }
    if (path.includes("/messages")) {
      return buckets.messageAttachments({ resourceId });
    }
    return buckets.resourceAttachments({ resourceId });
  } else {
    throw apiError(400, "Invalid upload path");
  }
};

export const storageService = {
  basePath,

  relativePath: (absolutePath: string) => {
    return path.relative(basePath, absolutePath);
  },

  absolutePath: (relativePath: string) => {
    return path.join(basePath, relativePath);
  },

  buckets,
  uploadStorageFromReq,
};
