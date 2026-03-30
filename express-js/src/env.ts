import z from "zod";
import dotenv from "dotenv";

dotenv.config();

export const env = z
  .object({
    NODE_ENV: z
      .enum(["development", "production", "test"])
      .default("development"),
    SERVER_PORT: z
      .string()
      .default("3000")
      .transform((val) => parseInt(val, 10)),
    DATABASE_URL: z.string().min(1, "DATABASE_URL is required"),
    SERVER_URL: z
      .string()
      .min(1, "SERVER_URL is required")
      .transform((v) => {
        const incorrectSuffixes = ["/api", "/api/", "/"];
        for (const suffix of incorrectSuffixes) {
          if (v.endsWith(suffix)) {
            return v.slice(0, -suffix.length);
          }
        }
        return v;
      }),
    WS_URL: z
      .string()
      .refine((v) => v.startsWith("ws://") || v.startsWith("wss://"))
      .optional(),
    JWT_SECRET: z.string().min(1, "JWT_SECRET is required"),
    FILE_STORAGE_PATH: z.string().min(1, "FILE_STORAGE_PATH is required"),
  })
  .transform((envs) => {
    return {
      ...envs,
      WS_URL:
        envs.WS_URL ??
        envs.SERVER_URL.replace("https://", "wss://").replace(
          "http://",
          "ws://"
        ),
    };
  })
  .parse(process.env);
