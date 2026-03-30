import type { WsInitOptions } from "./types";

export const DEFAULT_EVENTS = {
  auth: "auth",
  roomSubscribe: "room:subscribe",
  roomUnsubscribe: "room:unsubscribe",
  /** Client emits `echo` with `{ text: string }`; server replies on `echo:reply`. */
  echo: "echo",
  echoReply: "echo:reply",
} as const;

export type ResolvedEvents = {
  auth: string;
  roomSubscribe: string;
  roomUnsubscribe: string;
  echo: string;
  echoReply: string;
};

export const resolveEvents = (
  partial?: WsInitOptions["events"]
): ResolvedEvents => ({
  ...DEFAULT_EVENTS,
  ...partial,
});
