import { CacheStore } from "./cache-store";

const globalCache = new CacheStore(1000, 500);

export const cacheState = () => globalCache.cachedData();
export const clearGlobalCache = () => globalCache.clear();

const getStackBasedKey = (index: number = 3) => {
  const stack = new Error().stack;
  if (!stack) return undefined;
  return stack.split("\n")[index].trim();
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Callback = (...args: any[]) => Promise<any>;
export const cache = <T extends Callback>(
  fn: T,
  options: {
    keyParts?: ((...args: Parameters<T>) => string[]) | string[] | string;
    ttl?: number;
    tags?: ((...args: Parameters<T>) => string[]) | string[] | string;
    shouldCache?: (result: Awaited<ReturnType<T>>) => boolean;
  } = {},
  store?: CacheStore
) => {
  const staticKey = `${getStackBasedKey() ?? ""}::\n${fn.toString()}`;
  const { keyParts, ttl, tags, shouldCache } = options;

  store ??= globalCache;
  return async (...args: Parameters<T>): Promise<Awaited<ReturnType<T>>> => {
    const cacheKeyParts = keyParts
      ? typeof keyParts === "function"
        ? keyParts(...args)
        : typeof keyParts === "string"
        ? [keyParts]
        : keyParts
      : [];

    const toCacheTags = tags
      ? typeof tags === "function"
        ? tags(...args)
        : typeof tags === "string"
        ? [tags]
        : tags
      : [];
    const key = `${staticKey}-${JSON.stringify(args)}-${cacheKeyParts.join(
      "-"
    )}`;

    if (store.get(key)) return store.get(key) as Awaited<ReturnType<T>>;
    const res = (await fn(...args)) as Awaited<ReturnType<T>>;
    if (shouldCache && !shouldCache(res)) return res;
    store.store(key, res, toCacheTags, ttl);
    return res;
  };
};

export const revalidateTag = (tag: string, store?: CacheStore) => {
  store ??= globalCache;
  store.revalidateByTag(tag);
};
