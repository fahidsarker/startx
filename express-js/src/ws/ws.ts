import { Server, Socket } from "socket.io";

/** Verify a credential string (e.g. JWT); throw if invalid. */
export type WsVerifyToken<TUser = unknown> = (token: string) => TUser;

export type WsInitOptions<TUser = unknown> = {
  verifyToken: WsVerifyToken<TUser>;
  /** If set, the socket joins this room after successful auth (e.g. user id for direct emits). */
  getPersonalRoomId?: (user: TUser) => string | undefined;
  /** Payload key for room id on subscribe/unsubscribe (default `"roomId"`). */
  roomIdField?: string;
  /** Override default Socket.IO event names to match your client protocol. */
  events?: Partial<{
    auth: string;
    roomSubscribe: string;
    roomUnsubscribe: string;
  }>;
  onAuthenticated?: (socket: Socket, user: TUser) => void;
};

const DEFAULT_EVENTS = {
  auth: "auth",
  roomSubscribe: "room:subscribe",
  roomUnsubscribe: "room:unsubscribe",
} as const;

type ResolvedEvents = {
  auth: string;
  roomSubscribe: string;
  roomUnsubscribe: string;
};

const resolveEvents = (partial?: WsInitOptions["events"]): ResolvedEvents => ({
  ...DEFAULT_EVENTS,
  ...partial,
});

function socketUser<T>(socket: Socket): { user?: T } {
  return socket.data as { user?: T };
}

function extractRoomId(data: unknown, field: string): string | undefined {
  if (!data || typeof data !== "object" || !(field in data)) {
    return undefined;
  }
  const v = (data as Record<string, unknown>)[field];
  return typeof v === "string" ? v : undefined;
}

function extractToken(data: unknown): string | undefined {
  if (!data || typeof data !== "object" || !("token" in data)) {
    return undefined;
  }
  const v = (data as { token?: unknown }).token;
  return typeof v === "string" ? v : undefined;
}

let _io: Server | null = null;

export const initWSIO = <TUser,>(
  io: Server,
  options: WsInitOptions<TUser>
): Server => {
  if (_io) {
    return _io;
  }
  _io = io;
  const ev = resolveEvents(options.events);
  const roomIdField = options.roomIdField ?? "roomId";
  startIo(io, options, ev, roomIdField);
  return _io;
};

const startIo = <TUser,>(
  io: Server,
  options: WsInitOptions<TUser>,
  ev: ResolvedEvents,
  roomIdField: string
) => {
  io.on("connection", (socket) => {
    socket.on(ev.auth, (data) => handleAuth(socket, data, options, ev));
    socket.on(ev.roomSubscribe, (data) =>
      subscribeToRoom(socket, data, options, ev, roomIdField)
    );
    socket.on(ev.roomUnsubscribe, (data) =>
      unSubscribeFromRoom(socket, data, ev, roomIdField)
    );
    socket.on("disconnect", () => {
      socketUser<TUser>(socket).user = undefined;
      for (const room of socket.rooms) {
        if (room !== socket.id) {
          socket.leave(room);
        }
      }
    });
  });
};

export const io = () => {
  if (!_io) {
    throw new Error("Socket.io not initialized");
  }
  return _io;
};

const subscribeToRoom = <TUser,>(
  socket: Socket,
  data: unknown,
  _options: WsInitOptions<TUser>,
  ev: ResolvedEvents,
  roomIdField: string
) => {
  if (socketUser<TUser>(socket).user === undefined) {
    socket.emit(`${ev.roomSubscribe}:failure`, {
      message: "Not authenticated",
    });
    return;
  }
  const roomId = extractRoomId(data, roomIdField);
  if (!roomId) {
    socket.emit(`${ev.roomSubscribe}:failure`, {
      message: `No ${roomIdField} provided`,
    });
    return;
  }
  socket.join(roomId);
  socket.emit(`${ev.roomSubscribe}:success`, {
    message: `Subscribed to room ${roomId}`,
  });
};

const unSubscribeFromRoom = (
  socket: Socket,
  data: unknown,
  ev: ResolvedEvents,
  roomIdField: string
) => {
  const roomId = extractRoomId(data, roomIdField);
  if (!roomId) {
    socket.emit(`${ev.roomUnsubscribe}:failure`, {
      message: `No ${roomIdField} provided`,
    });
    return;
  }
  socket.leave(roomId);
  socket.emit(`${ev.roomUnsubscribe}:success`, {
    message: `Unsubscribed from room ${roomId}`,
  });
};

const handleAuth = <TUser,>(
  socket: Socket,
  data: unknown,
  options: WsInitOptions<TUser>,
  ev: ResolvedEvents
) => {
  const token = extractToken(data);
  if (!token) {
    socket.emit(`${ev.auth}:failure`, { message: "No token provided" });
    return;
  }
  try {
    const user = options.verifyToken(token);
    socketUser<TUser>(socket).user = user;
    const personal = options.getPersonalRoomId?.(user);
    if (personal) {
      socket.join(personal);
    }
    options.onAuthenticated?.(socket, user);
    socket.emit(`${ev.auth}:success`, { message: "Authentication successful" });
  } catch {
    socket.emit(`${ev.auth}:failure`, { message: "Invalid token" });
  }
};
