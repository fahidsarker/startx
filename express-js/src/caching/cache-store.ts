// import { logger } from '@/misc/logger.js';

const DEFAULT_REVALIDATION_IN_SEC = 60 * 60 * 10; // 10 hours
let debugMode = false;

export class CacheStore {
  static setDebugMode(mode: boolean) {
    debugMode = mode;
  }

  private cacheStore: Map<
    string,
    {
      value: unknown;
      expiresAt: number;
      lastAccessedAt: number;
      tags: string[];
    }
  >;
  private tagsStore: Map<string, string[]>; // point tags to keys
  private invalidKeyClearanceIntervalInMS: number;
  private maxSize: number;
  private clearanceBuffer: number;

  cachedData = () => {
    return [...this.cacheStore.entries()].map(([key, value]) => ({
      parent: key.split("::\n")[0].split("src")[1],
      ...value,
      key,
    }));
  };

  clear = () => {
    this.cacheStore.clear();
    this.tagsStore.clear();
  };

  private log = (metod: string, key: string, message: string) => {
    if (!debugMode) return;
    console.log(`
CacheStore: ${metod}
|
|___ key: ${key.split("\n")[0]}...
|
|___ ${message}
      `);
  };

  get cacheClearanceThreshold() {
    return this.maxSize + this.clearanceBuffer;
  }

  runCacheClearance = () => {
    console.log(
      `CacheStore: runCacheClearance init :: ${this.cacheStore.size} keys`
    );
    const now = Date.now();
    for (const [key, value] of this.cacheStore.entries()) {
      if (value.expiresAt < now) {
        this.remove(key);
      }
    }
    console.log(
      `CacheStore: runCacheClearance expired clean:: ${this.cacheStore.size} keys remain`
    );
    if (this.cacheStore.size > this.maxSize) {
      console.log(
        `CacheStore: runCacheClearance forceClean-init :: ${this.cacheStore.size} keys current`
      );
      const toRemoveCount = this.cacheStore.size - this.maxSize;

      // Convert to array and sort by lastAccessedAt
      const entries = [...this.cacheStore.entries()].sort(
        (a, b) => a[1].lastAccessedAt - b[1].lastAccessedAt
      );

      // Remove oldest accessed entries
      for (let i = 0; i < toRemoveCount; i++) {
        if (entries[i]) {
          this.remove(entries[i][0]);
        }
      }

      console.log(
        `CacheStore: runCacheClearance forceClean-ran clean:: ${this.cacheStore.size} keys remain`
      );
    }
  };

  private runCacheClearanceLoop = async () => {
    if (
      this.invalidKeyClearanceIntervalInMS < 10000 ||
      process.env.JEST_WORKER_ID !== undefined
    )
      return;
    while (true) {
      await new Promise((resolve) =>
        setTimeout(resolve, this.invalidKeyClearanceIntervalInMS)
      );
      this.runCacheClearance();
    }
  };

  constructor(
    maxSize: number,
    clearanceBuffer: number = 50,
    invalidKeyClearanceIntervalInMS: number = 1000 * 60 * 60 * 36 // 36 hours
  ) {
    this.cacheStore = new Map();
    this.tagsStore = new Map();
    this.invalidKeyClearanceIntervalInMS = invalidKeyClearanceIntervalInMS;
    this.maxSize = maxSize;
    this.clearanceBuffer = clearanceBuffer;
    this.runCacheClearanceLoop();
  }

  get currentSize() {
    return this.cacheStore.size;
  }

  store = <T>(
    key: string,
    value: T,
    tags: string[],
    revalidateInSec: number = DEFAULT_REVALIDATION_IN_SEC
  ) => {
    this.log(
      "store",
      key,
      `value: ${JSON.stringify(
        value
      )}, tags: ${tags}, revalidateInSec: ${revalidateInSec}`
    );
    const expiresAt = Date.now() + revalidateInSec * 1000;
    this.cacheStore.set(key, {
      value,
      expiresAt,
      tags,
      lastAccessedAt: Date.now(),
    });
    tags.forEach((tag) => {
      if (!this.tagsStore.has(tag)) this.tagsStore.set(tag, []);
      this.tagsStore.get(tag)?.push(key);
    });
    if (this.cacheStore.size > this.cacheClearanceThreshold) {
      this.runCacheClearance();
    }
  };

  private remove = (key: string) => {
    this.cacheStore.delete(key);
  };

  get = (key: string) => {
    const cache = this.cacheStore.get(key);
    if (!cache) {
      this.log("get", key, `cache not found`);
      return null;
    }
    if (cache.expiresAt < Date.now()) {
      this.revalidate(key);
      this.log("get", key, `cache expired`);
      return null;
    }
    this.log("get", key, `cache HIT!!!`);
    cache.lastAccessedAt = Date.now();
    return cache.value;
  };

  revalidateByTag = (tag: string) => {
    const keys = this.tagsStore.get(tag);
    if (!keys) {
      this.log("revalidateByTag", "", `tag: ${tag}, keys not found`);
      return;
    }
    this.tagsStore.delete(tag);
    this.log("revalidateByTag", "", `Clearing ${keys.length} keys`);
    keys.forEach(this.revalidate);
  };

  revalidate = (key: string) => {
    const cache = this.cacheStore.get(key);
    if (!cache) {
      this.log("revalidate", key, `cache not found`);
      return;
    }
    this.log("revalidate", key, `cache found. Removed`);
    this.remove(key);
  };
}
