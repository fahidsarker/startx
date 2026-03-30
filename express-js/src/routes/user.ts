import express from "express";
import { authRequired } from "../middleware/auth";
import { apiHandler, queryParams } from "../core/api-handler";
import { Res } from "../core/response";
import { db } from "../db";
import { ilike, or } from "drizzle-orm";
import { users } from "../db/schema";
import { getProfileOfUser } from "../services/profile";
import { delay } from "../utils";

const router = express.Router();

router.use(authRequired);

// GET /users - Get all users (except the authenticated user ? todo)
// params: search, limit, offset
router.get(
  "/",
  apiHandler(async (req) => {
    const { limit, offset, search } = queryParams(req);
    try {
      // const userId = getUser(req).userId;
      const allUsers = await db.query.users.findMany({
        limit,
        offset,
        columns: {
          id: true,
          name: true,
          email: true,
          createdAt: true,
        },
        where: search
          ? or(
              ilike(users.name, `%${search}%`),
              ilike(users.email, `%${search}%`)
            )
          : undefined,
      });
      return Res.json({ users: allUsers });
    } catch (error) {
      console.error("Get chats error:", error);
      return Res.error("Internal server error");
    }
  })
);

router.get(
  "/:uid",
  apiHandler(async (req) => {
    const { uid } = req.params;
    // todo: ensure the user has permission to view this profile
    const profile = await getProfileOfUser(uid);
    return Res.json({ user: profile });
  })
);

export default router;
