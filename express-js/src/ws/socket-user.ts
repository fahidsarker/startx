import type { Socket } from "socket.io";

export function socketUser<T>(socket: Socket): { user?: T } {
  return socket.data as { user?: T };
}
