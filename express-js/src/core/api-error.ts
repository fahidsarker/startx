export const apiError = (
  statusCode: number,
  message: string,
  stackTrace?: any
) => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const error = new Error(message) as any;
  error.statusCode = statusCode;
  error.stackTrace = stackTrace?.stack;
  return error;
};
