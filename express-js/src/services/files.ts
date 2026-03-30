import { cache } from "../caching/cache";
import { apiError } from "../core/api-error";
import { db, tables } from "../db";
import { env } from "../env";
import { storageService } from "./storage";
import jwt from "jsonwebtoken";

type FileJwtPayload = {
  filePath: string;
  fileId: string;
  expiary: number;
};

export const FILE_TOKEN_EXPIRY_MS = 12 * 60 * 60 * 1000; // 12 hours

export const getFilePathFromToken = (fileId: string, token: string) => {
  let payload: FileJwtPayload;
  try {
    payload = jwt.verify(token, env.JWT_SECRET) as FileJwtPayload;
  } catch (error) {
    throw apiError(400, "Invalid file token");
  }
  if (!payload || !payload.filePath) {
    throw apiError(400, "Invalid file token");
  }
  if (payload.fileId !== fileId) {
    throw apiError(400, "File ID does not match token");
  }
  const expiary = new Date(payload.expiary);
  const now = new Date();
  if (now > expiary) {
    throw apiError(400, "File token has expired");
  }
  return storageService.absolutePath(payload.filePath);
};

// for subsequent calls with same fileId and filePath, cache the result for 60 minutes
// to avoid generating multiple JWTs for the same file
export const createFileAccessUrlFromPath = cache(
  async (fileId: string, filePath: string) => {
    const jwtPayload = {
      filePath,
      fileId,
      expiary: Date.now() + FILE_TOKEN_EXPIRY_MS,
    } satisfies FileJwtPayload;

    const token = jwt.sign(jwtPayload, env.JWT_SECRET, {
      noTimestamp: true,
    });
    return `${env.SERVER_URL}/api/files/${fileId}?token=${token}`;
  },
  {
    keyParts: (fileId: string, filePath: string) => [fileId, filePath],
    ttl: 60 * 60, // 60 minutes
  }
);

export const createFilesEntriesInDB = async <T>({
  files,
  userId,
  before,
  parentType,
  after,
}: {
  files: Express.Multer.File[];
  userId: string;
  parentType: "user";
  before?: (tx: (typeof db.transaction)["arguments"][0]) => Promise<void>;
  after?: (tx: (typeof db.transaction)["arguments"][0]) => Promise<T>;
}) => {
  const fileContents = files.map((file) => {
    return {
      uploaderId: userId,
      parentId: userId,
      parentType: parentType,
      ext: file.originalname.substring(file.originalname.lastIndexOf(".") + 1),
      mimeType: file.mimetype,
      relativePath: storageService.relativePath(file.path),
      size: file.size,
      originalName: file.originalname,
      fileType: "image",
    } satisfies typeof tables.files.$inferInsert;
  });

  return await db.transaction(async (tx) => {
    if (before) {
      await before(tx);
    }

    await tx.insert(tables.files).values(fileContents);

    if (after) {
      return await after(tx);
    }
  });
};
