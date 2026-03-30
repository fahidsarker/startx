import express from "express";
import { createServer } from "http";
import { Server } from "socket.io";
import cors from "cors";
import helmet from "helmet";
import { env } from "./env";

const app = express();
const server = createServer(app);
import authRoutes from "./routes/auth";
import userRoutes from "./routes/user";
import profileRoutes from "./routes/profile";

import { globalErrorHandler } from "./middleware/global-error-handle";
import { initWSIO } from "./ws/ws";
import { authService } from "./services/auth";

initWSIO(
  new Server(server, {
    cors: {
      origin: "*", // Configure later appropriately for production
      methods: ["GET", "POST"],
    },
  }),
  {
    verifyToken: (token) => authService.verifyToken(token),
    getPersonalRoomId: (user) => user.userId,
  }
);

const PORT = env.SERVER_PORT || 8080;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// Custom logging middleware
app.use((req, res, next) => {
  res.on("finish", () => {
    console.log(
      `${new Date().toLocaleString(undefined, {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false,
      })}\t${req.method}\t${req.originalUrl}\t${res.statusCode}`
    );
  });
  next();
});



// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
  });
});

app.get("/ping", (req, res) => {
  res.json({
    status: "ok",
    pong: true,
    timestamp: new Date().toISOString(),
    apiVersion: "1.0.0",
    httpUrl: env.SERVER_URL,
    wsUrl: env.WS_URL,
  });
});

app.post("/log", (req, res) => {
  const body = req.body;
  const logs = body.logs;
  if (logs && Array.isArray(logs)) {
    logs.forEach((log: any) => {
      console.log(`[CLIENT LOG] ${log}`);
    });
  }
  return res.status(200).send("Loged");
});

app.use("/api/auth", authRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/users", userRoutes);


// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// Error handling middleware
app.use(globalErrorHandler);

// Start server
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 WebSocket server ready`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  console.log(`📋 API base URL: http://localhost:${PORT}/api`);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, shutting down gracefully");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  console.log("SIGINT received, shutting down gracefully");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});
