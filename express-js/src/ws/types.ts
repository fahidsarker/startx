import type { Socket } from "socket.io";

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
    echo: string;
    echoReply: string;
  }>;
  onAuthenticated?: (socket: Socket, user: TUser) => void;
};
