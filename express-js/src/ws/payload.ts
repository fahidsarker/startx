export function extractRoomId(data: unknown, field: string): string | undefined {
  if (!data || typeof data !== "object" || !(field in data)) {
    return undefined;
  }
  const v = (data as Record<string, unknown>)[field];
  return typeof v === "string" ? v : undefined;
}

export function extractToken(data: unknown): string | undefined {
  if (!data || typeof data !== "object" || !("token" in data)) {
    return undefined;
  }
  const v = (data as { token?: unknown }).token;
  return typeof v === "string" ? v : undefined;
}

export function extractEchoText(data: unknown): string {
  if (typeof data === "string") {
    return data;
  }
  if (data && typeof data === "object" && "text" in data) {
    const t = (data as { text?: unknown }).text;
    if (typeof t === "string") {
      return t;
    }
  }
  return "";
}
