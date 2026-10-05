// The error the app shows. Keep the message in plain language.
export type ErrorCode =
  | 'validation_failed'
  | 'unauthorized'
  | 'conflict'
  | 'unavailable';

export class AppError extends Error {
  constructor(
    readonly statusCode: number,
    readonly code: ErrorCode,
    message: string,
  ) {
    super(message);
    this.name = 'AppError';
  }
}
