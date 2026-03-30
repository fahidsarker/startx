import type { Server } from "socket.io";
import { resolveEvents } from "./events";
import { startIo } from "./connection";
import type { WsInitOptions } from "./types";

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

export const io = () => {
  if (!_io) {
    throw new Error("Socket.io not initialized");
  }
  return _io;
};
