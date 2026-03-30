import { randomBytes } from "crypto";
import type { Socket } from "socket.io";
import type { ResolvedEvents } from "./events";
import { extractEchoText } from "./payload";
import { socketUser } from "./socket-user";

function randomEchoSuffix(): string {
  const parts = ["spark", "flux", "nova", "pulse", "orbit"];
  const word = parts[Math.floor(Math.random() * parts.length)];
  return `${word}-${randomBytes(3).toString("hex")}`;
}

export const handleEcho = <TUser,>(
  socket: Socket,
  data: unknown,
  ev: ResolvedEvents
) => {
  if (socketUser<TUser>(socket).user === undefined) {
    socket.emit(ev.echoReply, {
      error: "Not authenticated",
    });
    return;
  }
  const original = extractEchoText(data);
  const suffix = randomEchoSuffix();
  const message = original.length > 0 ? `${original} · ${suffix}` : suffix;
  socket.emit(ev.echoReply, {
    original,
    suffix,
    message,
  });
};
