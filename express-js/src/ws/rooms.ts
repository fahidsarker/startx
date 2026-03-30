import type { Socket } from "socket.io";
import type { ResolvedEvents } from "./events";
import { extractRoomId } from "./payload";
import { socketUser } from "./socket-user";
import type { WsInitOptions } from "./types";

export const subscribeToRoom = <TUser,>(
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

export const unSubscribeFromRoom = (
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
