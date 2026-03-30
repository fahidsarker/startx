# Express.js starter

TypeScript API template: **Express**, **PostgreSQL** via **Drizzle ORM**, **JWT** auth, **Socket.IO**, **Helmet** + **CORS**, and optional local file uploads (Multer).

This project is meant to be used with **[Bun](https://bun.sh)** for installs and scripts. Other package managers can run the same `package.json` scripts, but the docs and defaults assume Bun.

## Prerequisites

- [Bun](https://bun.sh) (latest stable) or changeable to another package manager
- PostgreSQL

## Other package managers and runtimes

### npm, pnpm, or Yarn

Use whichever tool you prefer to install dependencies; `package.json` is standard:

| Instead of…   | Use…                                     |
| ------------- | ---------------------------------------- |
| `bun install` | `npm install`, `pnpm install`, or `yarn` |
| `bun run …`   | `npm run …`, `pnpm …`, or `yarn …`       |

Keep a single lockfile in git: this template includes `bun.lock`. If you switch managers, remove `bun.lock` and commit the one your tool generates (`package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`).

**Note:** The `start` and `dev` scripts still invoke **Bun** (`bun run src/index.ts`, `bun --watch …`). Installing with npm/pnpm/yarn does not change that—those commands need Bun on your PATH unless you override the scripts (next subsection).

### Node.js instead of Bun

Node does not run `.ts` files directly. To run the app without Bun:

1. Add a dev runner such as [tsx](https://github.com/privatenumber/tsx):

   ```bash
   npm install -D tsx
   ```

   (Use `pnpm add -D tsx` or `yarn add -D tsx` if you use those.)

2. In `package.json`, replace the Bun-specific script commands, for example:

   | Script  | Bun (default)              | Node-oriented example    |
   | ------- | -------------------------- | ------------------------ |
   | `dev`   | `bun --watch src/index.ts` | `tsx watch src/index.ts` |
   | `start` | `bun run src/index.ts`     | `tsx src/index.ts`       |

   For production-style runs without a TS runner, use `npm run build` then `node dist/src/index.js` (see `main` in `package.json`).

3. Drizzle and TypeScript tooling already run on Node: `db:generate`, `db:migrate`, `db:studio`, and `build` work the same after `npm install` / `pnpm install` / `yarn`.

### Deno or other runtimes

This template targets Bun or Node + Express. Adapting to Deno or another runtime is possible but not documented here; you would replace the process runner, resolve any Node-specific APIs, and adjust dependency imports as needed.

## Quick start

1. **Install dependencies**

   ```bash
   bun install
   ```

2. **Environment**

   Copy the example env file and edit values:

   ```bash
   cp .env.example .env
   ```

   | Variable            | Description                                                           |
   | ------------------- | --------------------------------------------------------------------- |
   | `NODE_ENV`          | `development`, `production`, or `test`                                |
   | `SERVER_PORT`       | HTTP port (default `3000`)                                            |
   | `SERVER_URL`        | Public base URL of the API (no trailing `/`, `/api`, or `/api/`)      |
   | `DATABASE_URL`      | PostgreSQL connection string                                          |
   | `JWT_SECRET`        | Secret for signing access tokens                                      |
   | `FILE_STORAGE_PATH` | Root directory for uploaded files on disk                             |
   | `WS_URL`            | Optional; defaults from `SERVER_URL` (`http` → `ws`, `https` → `wss`) |

3. **Database**

   Generate SQL migrations from `src/db/schema.ts`, then apply them (with `DATABASE_URL` set):

   ```bash
   bun run db:generate
   bun run db:migrate
   ```

   Inspect the database with Drizzle Studio:

   ```bash
   bun run db:studio
   ```

4. **Run the server**

   ```bash
   bun run dev
   ```

   `dev` uses file watching for reloads. For a non-watch run, use `bun run start` (runs `src/index.ts` with Bun). For a compiled build, use `bun run build` and run the output under `dist/` with your process manager of choice.

## Scripts

| Command               | Purpose                               |
| --------------------- | ------------------------------------- |
| `bun run dev`         | Watch mode (reload on change)         |
| `bun run start`       | Run `src/index.ts` with Bun           |
| `bun run build`       | Typecheck / emit with `tsc` → `dist/` |
| `bun run db:generate` | Drizzle: generate migrations          |
| `bun run db:migrate`  | Drizzle: run migrations               |
| `bun run db:studio`   | Drizzle Studio UI                     |

## Directory structure

Repository layout (excluding `node_modules/` and build output; `dist/` appears after `bun run build`). The `drizzle/` folder is created when you run `bun run db:generate`.

```
express-js/
├── drizzle/                    # SQL migrations (generated)
├── src/
│   ├── caching/
│   │   ├── cache-store.ts
│   │   └── cache.ts
│   ├── core/
│   │   ├── api-error.ts
│   │   ├── api-handler.ts
│   │   ├── multer.ts
│   │   └── response.ts
│   ├── db/
│   │   ├── index.ts
│   │   └── schema.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   └── global-error-handle.ts
│   ├── routes/
│   │   ├── auth.ts
│   │   ├── profile.ts
│   │   └── user.ts
│   ├── services/
│   │   ├── auth.ts
│   │   ├── files.ts
│   │   ├── profile.ts
│   │   └── storage.ts
│   ├── types/
│   │   ├── core-types.ts
│   │   ├── db-types.ts
│   │   └── status-codes.ts
│   ├── validators/
│   │   └── auth.ts
│   ├── ws/
│   │   └── ws.ts
│   ├── constants.ts
│   ├── env.ts
│   ├── index.ts
│   └── utils.ts
├── .env.example
├── .gitignore
├── bun.lock
├── drizzle.config.ts
├── package.json
├── readme.md
└── tsconfig.json
```

### What lives where

| Area                | Role                                                 |
| ------------------- | ---------------------------------------------------- |
| `src/index.ts`      | Express app, HTTP server, Socket.IO                  |
| `src/env.ts`        | Environment validation (Zod)                         |
| `src/db/`           | Drizzle client + PostgreSQL schema                   |
| `src/routes/`       | HTTP route modules                                   |
| `src/services/`     | Business logic (auth, profile, files, storage paths) |
| `src/middleware/`   | JWT gate + global error handler                      |
| `src/core/`         | Shared API helpers, Multer config, errors, responses |
| `src/ws/`           | Socket.IO connection handling                        |
| `src/caching/`      | Cache abstraction + store                            |
| `src/validators/`   | Zod (etc.) validators for routes                     |
| `src/types/`        | Shared TypeScript types                              |
| `drizzle.config.ts` | Drizzle Kit config                                   |

## HTTP API (overview)

- `GET /health` — liveness-style JSON
- `GET /ping` — JSON including `httpUrl` / `wsUrl` from env
- `POST /log` — accepts `{ logs: string[] }` for server-side logging (development aid)
- `/api/auth` — registration / login (see `src/routes/auth.ts`)
- `/api/profile` — authenticated profile routes
- `/api/users` — authenticated user listing and lookup

Exact payloads and status codes live next to the handlers in `src/routes/` and `src/core/response.ts`.

## WebSocket (Socket.IO)

After connecting, clients should emit the configured `auth` event with a JWT. Valid tokens attach the user to the socket; optional room subscribe/unsubscribe events are defined in `src/ws/ws.ts` (defaults: `auth`, `room:subscribe`, `room:unsubscribe`).

## File uploads (Multer)

Disk layout is driven by `FILE_STORAGE_PATH` and `src/services/storage.ts`:

- Profile uploads: requests under `/api/profile/…` → `profile_photos/<userId>/`
- Generic resource uploads: `/api/uploads/resource/:resourceId/…` → `resource_attachments/<resourceId>/`
- Same base with `/messages` in the path → `message_attachments/<resourceId>/`

Wire your own Express routes that use the shared Multer instance and match these URL patterns so `uploadStorageFromReq` resolves the correct folder.

## Security notes

- Set a strong `JWT_SECRET` in production.
- Tighten CORS and Socket.IO `origin` (currently permissive in `src/index.ts`) before exposing the API publicly.
- Review file upload limits and MIME filters in `src/core/multer.ts`.
