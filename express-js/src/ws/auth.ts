import type { Socket } from "socket.io";
import type { ResolvedEvents } from "./events";
import { extractToken } from "./payload";
import { socketUser } from "./socket-user";
import type { WsInitOptions } from "./types";

export const handleAuth = <TUser,>(
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
