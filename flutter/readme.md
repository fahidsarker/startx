# Flutter starter

Flutter client template: **Riverpod** (with code generation), **go_router**, **Dio** for REST, **Socket.IO** aligned with the **express-js** API, **solid_shared_pref** for persisted auth, and Material UI with **google_fonts** and light/dark theming.

This app is meant to pair with **[Express.js + TypeScript API](../express-js/readme.md)** (same auth routes, profile APIs, and WebSocket events). Point the client at your API base URL via Dart compile-time defines (see below).

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) stable channel (SDK `^3.9.2` per `pubspec.yaml`)
- A running backend that matches this template’s routes and Socket.IO contract (e.g. the **express-js** starter)

## Quick start

1. **Install dependencies**

   ```bash
   cd flutter
   flutter pub get
   ```

2. **Generate Riverpod code** (after cloning or editing `@riverpod` providers)

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **API base URL**

   The HTTP client and Socket.IO client both use `API_URL` from `lib/core/constants.dart`:

   - Default: `http://localhost:3000` (matches the Express template’s usual port).
   - Override at **compile time**:

     ```bash
     flutter run --dart-define=api_url=https://your-api.example.com
     ```

     For **web** release builds, pass the same define to `flutter build web`.

4. **Run the app**

   ```bash
   flutter run
   ```

   Pick a device (simulator, emulator, Chrome, etc.) when prompted. On **web**, path-based URLs are enabled via conditional `url_strategy` imports in `lib/main.dart`.

## Commands (cheat sheet)

| Command | Purpose |
| ------- | ------- |
| `flutter pub get` | Resolve dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate `*.g.dart` for Riverpod |
| `dart run build_runner watch --delete-conflicting-outputs` | Watch mode while editing providers |
| `flutter run` | Run on attached device / browser |
| `flutter run --dart-define=api_url=...` | Run with a custom API / Socket.IO origin |
| `flutter test` | Run widget tests under `test/` |
| `flutter analyze` | Static analysis (`analysis_options.yaml` + lints) |

## Configuration

| Define | Where used | Default |
| ------ | ---------- | ------- |
| `api_url` | `lib/core/constants.dart` → `API_URL` | `http://localhost:3000` |

REST calls use this value as Dio’s `baseUrl`. Socket.IO connects to the same origin (`socket_io_provider.dart`).

## Main dependencies

Runtime packages from `pubspec.yaml` (grouped by role):

| Package | Role |
| ------- | ---- |
| `hooks_riverpod`, `flutter_riverpod`, `riverpod_annotation` | App-wide state; `@riverpod` providers |
| `flutter_hooks` | Hook-style composition in widgets |
| `provider` | `ThemeProvider` (`ChangeNotifier`) alongside Riverpod in `main.dart` |
| `go_router` | Declarative routes, redirects from auth state |
| `dio` | HTTP client; bearer token from auth state |
| `resultx` | `Result` / `ApiError` style API responses in `lib/core/api.dart` |
| `solid_shared_pref` | Persistent preferences (init in `main.dart`) |
| `socket_io_client` | Realtime; protocol helpers in `lib/socket_io/app_socket.dart` |
| `google_fonts`, `cupertino_icons`, `font_awesome_flutter` | Typography and icons |
| `delightful_toast` | Toasts |
| `cached_network_image` | Network images with caching |
| `image_picker`, `file_picker` | Profile / attachment flows |
| `giphy_picker`, `any_link_preview` | Rich media / link previews in the UI |

**Dev:** `flutter_lints`, `riverpod_generator`, `build_runner`, `flutter_test`.

## Directory structure

Layout focuses on `lib/`; platform folders are standard Flutter scaffolding. Excludes `build/`, `.dart_tool/`, and generated `*.g.dart` (they appear after `build_runner`).

```
flutter/
├── assets/
│   └── backgrounds/          # Referenced from pubspec assets
├── lib/
│   ├── core/
│   │   ├── api.dart          # Api wrapper (Dio + Result)
│   │   ├── api_paths.dart    # REST path enums (auth, profile, users)
│   │   ├── constants.dart    # API_URL (dart-define)
│   │   ├── theme/            # AppTheme, colors, typography
│   │   ├── url_strategy_stub.dart
│   │   └── url_strategy_web.dart
│   ├── extensions/           # Dart / Riverpod / Result helpers
│   ├── models/
│   │   └── user.dart
│   ├── providers/            # Riverpod (@riverpod); *.g.dart generated
│   │   ├── api_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── socket_io_provider.dart
│   │   ├── theme_provider.dart # ChangeNotifier theme mode (wired in main.dart)
│   │   ├── users_provider.dart
│   │   └── state_provider.dart
│   ├── screens/
│   │   ├── auth/             # login, registration
│   │   ├── home/             # shell child routes: dashboard, profile
│   │   ├── init/             # initial redirect
│   │   ├── welcome.dart
│   │   └── error_screen.dart
│   ├── socket_io/
│   │   └── app_socket.dart   # Events + AppSocket (matches express-js ws.ts)
│   ├── utils/
│   ├── widgets/              # Forms, toolbar, profiles, users, shared UI
│   ├── main.dart
│   ├── preferences.dart
│   └── router.dart           # go_router + auth redirects
├── test/
│   └── widget_test.dart
├── web/, android/, ios/, linux/, macos/, windows/
├── analysis_options.yaml
├── pubspec.yaml
└── readme.md
```

### What lives where

| Area | Role |
| ---- | ---- |
| `lib/main.dart` | `ProviderScope`, shared prefs init, web URL strategy, `MaterialApp.router` + theme |
| `lib/router.dart` | `GoRouter` routes; redirect when logged in / out |
| `lib/core/api.dart` | Typed `get` / `post` with `resultx` |
| `lib/core/api_paths.dart` | Central REST paths for auth, profile, users |
| `lib/providers/auth_provider.dart` | Session / token (drives API and socket) |
| `lib/providers/api_provider.dart` | `Dio` + `Api` instances |
| `lib/providers/socket_io_provider.dart` | Socket lifecycle, auth emit on connect |
| `lib/socket_io/app_socket.dart` | Event names and subscribe/unsubscribe helpers aligned with **express-js** `src/ws/ws.ts` |
| `lib/screens/` | Feature screens and shell layout |
| `lib/widgets/` | Reusable UI (login/signup, profile sections, toolbar, etc.) |

## Navigation (overview)

| Path | Screen |
| ---- | ------ |
| `/` | Initial redirect (welcome vs dashboard) |
| `/welcome` | Welcome |
| `/login`, `/registration` | Auth |
| `/dashboard`, `/profile` | Shell under `HomeScreen` (authenticated) |

Unauthenticated access to `/profile` or `/dashboard` redirects to `/login`; authenticated users hitting auth/welcome routes redirect to `/dashboard`.

## REST API (overview)

Paths are enumerated in `lib/core/api_paths.dart` and mirror the express-js template:

- `POST /api/auth/login`, `POST /api/auth/register`
- `GET /api/profile`, profile update endpoints
- `GET /api/users`, `GET /api/users/:id`

Exact payloads and errors follow the server implementation in `express-js/src/routes/`.

## WebSocket (Socket.IO)

After connect, the client emits **`auth`** with `{ "token": "<JWT>" }`, matching the server’s `DEFAULT_EVENTS` in `express-js/src/ws/ws.ts`. Success/failure events use the `:success` / `:failure` suffix pattern. Use **`AppSocket`** in `lib/socket_io/app_socket.dart` for typed subscribe/unsubscribe to rooms (`room:subscribe` / `room:unsubscribe` by default).

Ensure `api_url` matches your Socket.IO server origin (same host/port as the HTTP API in the bundled Express setup).

## Security notes

- Treat stored tokens like any mobile secret: the template uses shared preferences; harden for production (secure storage, token refresh, certificate pinning) as needed.
- CORS and Socket.IO `origin` on the server must allow your app’s origins in production (see **express-js** readme).

## Related

- **Backend template:** [Express.js readme](../express-js/readme.md)
- **Monorepo index:** [Starter templates readme](../readme.md)
