import express, { Request, Response } from "express";
import { eq } from "drizzle-orm";
import { db } from "../db";
import { users } from "../db/schema";
import { authService } from "../services/auth";
import {
  registerSchema,
  loginSchema,
  RegisterInput,
  LoginInput,
} from "../validators/auth";
import { getProfileOfUser } from "../services/profile";

const router = express.Router();

// POST /auth/register
router.post("/register", async (req: Request, res: Response) => {
  try {
    const validatedData: RegisterInput = registerSchema.parse(req.body);
    const { name, email, password } = validatedData;

    // Check if user already exists
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.email, email))
      .limit(1);

    if (existingUser.length > 0) {
      return res.status(400).json({ error: "User already exists" });
    }

    // Hash password
    const passwordHash = await authService.hashPassword(password);

    // Create user
    const [newUser] = await db
      .insert(users)
      .values({
        name,
        email,
        passwordHash,
      })
      .returning({
        id: users.id,
        name: users.name,
        email: users.email,
        createdAt: users.createdAt,
      });

    // Generate token
    // todo: move to session based auth later
    // currently using JWT for simplicity
    const token = authService.generateToken({
      userId: newUser.id,
      email: newUser.email,
    });

    res.status(201).json({
      message: "User registered successfully",
      user: newUser,
      token,
    });
  } catch (error: any) {
    if (error.name === "ZodError") {
      return res
        .status(400)
        .json({ error: "Invalid input", details: error.errors });
    }
    console.error("Registration error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /auth/login
router.post("/login", async (req: Request, res: Response) => {
  try {
    const validatedData: LoginInput = loginSchema.parse(req.body);
    const { email, password } = validatedData;

    // Find user
    const [credentials] = await db
      .select({
        id: users.id,
        email: users.email,
        passwordHash: users.passwordHash,
      })
      .from(users)
      .where(eq(users.email, email))
      .limit(1);

    if (!credentials) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // Verify password
    const isValidPassword = await authService.comparePassword(
      password,
      credentials.passwordHash
    );

    if (!isValidPassword) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // Generate token
    const token = authService.generateToken({
      userId: credentials.id,
      email: credentials.email,
    });

    res.json({
      message: "Login successful",
      user: await getProfileOfUser(credentials.id),
      token,
    });
  } catch (error: any) {
    if (error.name === "ZodError") {
      return res
        .status(400)
        .json({ error: "Invalid input", details: error.errors });
    }
    console.error("Login error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
