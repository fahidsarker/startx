# Starter templates

Small, copy-paste-friendly project starters.

## Templates

- **[Express.js + TypeScript API](express-js/readme.md)** — Express, Drizzle (PostgreSQL), JWT auth, Socket.IO, and file upload helpers. Use **Bun** for install and scripts (see that readme).
- **[Flutter client](flutter/readme.md)** — Riverpod, go_router, Dio, Socket.IO client aligned with the Express API; optional pairing with **express-js** for a full-stack starter.

## Download templates

Scripts live under `scripts/`: **`get-template.sh`** (Bash) and **`get-template.ps1`** (PowerShell). Both clone [fahidsarker/startx](https://github.com/fahidsarker/startx) shallowly, then copy the requested template folders. Override the repo with `STARTX_REPO` (or `--repo OWNER/NAME`).

### Bash (`get-template.sh`)

```bash
curl -fsSL https://raw.githubusercontent.com/fahidsarker/startx/main/scripts/get-template.sh | bash -s -- <template_name> --out <output_folder>
```

Example:

```bash
curl -fsSL https://raw.githubusercontent.com/fahidsarker/startx/main/scripts/get-template.sh | bash -s -- express-js --out ./my-api
```

### PowerShell (`get-template.ps1`)

Save the script, then run it (requires `git` on `PATH`):

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fahidsarker/startx/main/scripts/get-template.ps1" -OutFile get-template.ps1
.\get-template.ps1 express-js --out .\my-api
```

From a clone of this repo you can run `.\scripts\get-template.ps1` with the same arguments as the shell script (`--prefix`, `-Force` / `--force`, multiple templates, and so on).
