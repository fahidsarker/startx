import express from "express";
import fs from "fs";
import mime from "mime";
import { apiHandler } from "../core/api-handler";
import { Res } from "../core/response";
import { FILE_TOKEN_EXPIRY_MS, getFilePathFromToken } from "../services/files";

import { apiError } from "../core/api-error";
const router = express.Router();

// Apply authentication middleware to all chat routes
router.get(
  "/:fid",
  apiHandler(async (req, res) => {
    const token = req.query.token;
    console.log("token", token);
    if (typeof token !== "string") {
      throw apiError(400, "Invalid or missing token");
    }

    const filePath = getFilePathFromToken(req.params.fid, token);

    fs.stat(filePath, (err, stats) => {
      if (err) {
        console.log("error", err);
        return res.sendStatus(404);
      };

      res.setHeader("Content-Length", stats.size);
      res.setHeader(
        "Content-Type",
        mime.getType(filePath) || "application/octet-stream"
      );
      res.setHeader(
        "Cache-Control",
        `public, max-age=${FILE_TOKEN_EXPIRY_MS / 1000}`
      ); // 12 hours
      res.setHeader("Last-Modified", stats.mtime.toUTCString());
      res.setHeader(
        "ETag",
        `"${stats.size}-${stats.mtime.getTime()}-${req.params.fid}"`
      );
      fs.createReadStream(filePath).pipe(res);
    });

    return Res.none();
  })
);

export default router;
