import type { Server } from "socket.io";
import { handleAuth } from "./auth";
import type { ResolvedEvents } from "./events";
import { handleEcho } from "./echo";
import { subscribeToRoom, unSubscribeFromRoom } from "./rooms";
import { socketUser } from "./socket-user";
import type { WsInitOptions } from "./types";

export const startIo = <TUser,>(
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
    socket.on(ev.echo, (data) => handleEcho(socket, data, ev));
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
