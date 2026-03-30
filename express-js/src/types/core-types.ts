export type NeverPromise<T> = T extends Promise<unknown>
  ? "ERROR: PROMISE CAN NOT BE USED"
  : T extends Array<infer U>
  ? Array<NeverPromise<U>>
  : T extends object
  ? { [K in keyof T]: NeverPromise<T[K]> }
  : T;

export type ApiData = {
  [k: string]: NeverPromise<unknown>;
};
