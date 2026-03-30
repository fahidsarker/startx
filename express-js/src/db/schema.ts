import { relations } from "drizzle-orm";
import {
  pgTable,
  varchar,
  timestamp,
  boolean,
  doublePrecision,
} from "drizzle-orm/pg-core";

const primaryId = (name: string) =>
  varchar(name, { length: 255 })
    .primaryKey()
    .$default(() => crypto.randomUUID());

// Users table
export const users = pgTable("users", {
  id: primaryId("id"),
  name: varchar("name", { length: 255 }).notNull(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  passwordHash: varchar("password_hash", { length: 255 }).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});


export const files = pgTable("files", {
  id: primaryId("id"),
  uploaderId: varchar("uploader_id", { length: 255 })
    .notNull()
    .references(() => users.id),
  parentId: varchar("parent_id", { length: 255 }).notNull(), // denotes the entity this file is associated with -> user id, message id, etc.
  parentType: varchar("parent_type", { length: 100 })
    .$type<"user" | "message" | "chat">()
    .notNull(), // denotes the type of entity the file is associated with -> "user", "message
  relativePath: varchar("relative_path", { length: 1000 }).notNull(),
  thumbnailPath: varchar("thumbnail_path", { length: 1000 }), // optional thumbnail path for images/videos
  originalName: varchar("original_name", { length: 255 }).notNull(),
  size: doublePrecision("size").notNull(),
  mimeType: varchar("mime_type", { length: 255 }).notNull(),
  ext: varchar("ext", { length: 50 }).notNull(),
  width: doublePrecision("width"),
  height: doublePrecision("height"),
  duration: doublePrecision("duration"), // for audio/video files
  createdAt: timestamp("created_at").defaultNow().notNull(),
  fileType: varchar("file_type", { length: 50 })
    .$type<"image" | "video" | "audio" | "document" | "other">()
    .notNull(),
  deleted: boolean("deleted").default(false).notNull(), // used to soft delete files -> a script can be run later to permanently delete files marked as deleted
});



// Relations
export const usersRelations = relations(users, ({ many }) => ({
  files: many(files),
  profilePhotos: many(files, {
    relationName: "userProfilePhotos",
  }),
}));


export const filesRelations = relations(files, ({ one }) => ({
  uploader: one(users, {
    fields: [files.uploaderId],
    references: [users.id],
  }),
  parentUser: one(users, {
    fields: [files.parentId],
    references: [users.id],
    relationName: "userProfilePhotos",
  }),

}));


