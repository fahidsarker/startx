import { files, users } from "../db/schema";

export type FileRow = typeof files.$inferSelect;
export type UserRow = typeof users.$inferSelect;