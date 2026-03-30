import { Request } from "express";
import multer from "multer";
import crypto from "crypto";

import { getUser } from "../services/auth";

import { apiError } from "./api-error";
import { storageService } from "../services/storage";

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // todo: fallback to a default path if env.FILE_STORAGE_PATH is not set
    cb(null, storageService.uploadStorageFromReq(req)); //  Ensure this directory exists
  },
  filename: (req, file, cb) => {
    const rand = crypto.randomUUID();
    const originalName = file.originalname;
    const extension = originalName.substring(
      originalName.lastIndexOf("."),
      originalName.length
    );
    cb(null, `${rand}${extension}`);
  },
});

export const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept only image files
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"));
    }
  },
});
