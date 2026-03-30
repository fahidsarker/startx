#!/usr/bin/env bash
# Copy template directories from fahidsarker/startx (or STARTX_REPO / --repo).
set -euo pipefail

REPO="${STARTX_REPO:-fahidsarker/startx}"
OUT=""
PREFIX=""
FORCE=false
TEMPLATES=()

usage() {
  cat >&2 <<'EOF'
Usage: get-template.sh [options] <template> [<template> ...]

Clone the repo once (shallow), then copy each template folder to a destination.

Options:
  --repo OWNER/NAME   GitHub repo (default: fahidsarker/startx, or STARTX_REPO)
  --out DIR           Output directory (only with exactly one template)
  --prefix DIR        Place each template under DIR/<name>/ (optional)
  -f, --force         Overwrite non-empty destination without prompting
  -h, --help          Show this help

Examples:
  get-template.sh express-js
  get-template.sh express-js --out ./my-api
  get-template.sh express-js other-template
  get-template.sh --prefix ./starters express-js other-template
EOF
}

cleanup() {
  if [[ -n "${tmpdir:-}" && -d "${tmpdir}" ]]; then
    rm -rf "${tmpdir}"
  fi
}

dir_nonempty() {
  local d="$1"
  [[ -e "$d" ]] && [[ -n "$(ls -A "$d" 2>/dev/null || true)" ]]
}

confirm_overwrite() {
  local dest="$1"
  if [[ "$FORCE" == true ]]; then
    return 0
  fi
  if [[ -t 0 ]]; then
    read -r -p "Destination is not empty: ${dest}. Remove and replace? [y/N] " ans
    [[ "${ans:-}" == [yY] || "${ans:-}" == [yY][eE][sS] ]]
  else
    echo "Error: ${dest} exists and is not empty. Use --force to overwrite (non-interactive)." >&2
    return 1
  fi
}

ensure_parent() {
  local dest="$1"
  local parent
  parent=$(dirname "$dest")
  if [[ "$parent" != "." && "$parent" != "/" ]]; then
    mkdir -p "$parent"
  fi
}

list_template_hints() {
  local root="$1"
  echo "Top-level directories in clone:" >&2
  shopt -s nullglob
  local d
  for d in "$root"/*; do
    [[ -d "$d" ]] || continue
    local base
    base=$(basename "$d")
    [[ "$base" == .* ]] && continue
    printf '  %s\n' "$base" >&2
  done
  shopt -u nullglob
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { echo "Error: --repo requires OWNER/NAME" >&2; exit 1; }
      REPO="$2"
      shift 2
      ;;
    --out)
      [[ $# -ge 2 ]] || { echo "Error: --out requires a directory" >&2; exit 1; }
      OUT="$2"
      shift 2
      ;;
    --prefix)
      [[ $# -ge 2 ]] || { echo "Error: --prefix requires a directory" >&2; exit 1; }
      PREFIX="$2"
      shift 2
      ;;
    --force|-f)
      FORCE=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      echo "Error: unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      TEMPLATES+=("$1")
      shift
      ;;
  esac
done

if [[ ${#TEMPLATES[@]} -eq 0 ]]; then
  echo "Error: at least one template name is required." >&2
  usage
  exit 1
fi

if [[ -n "$OUT" && ${#TEMPLATES[@]} -gt 1 ]]; then
  echo "Error: --out can only be used with exactly one template." >&2
  exit 1
fi

if [[ -n "$OUT" && -n "$PREFIX" ]]; then
  echo "Error: use only one of --out and --prefix." >&2
  exit 1
fi

tmpdir=""
trap cleanup EXIT
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/startx_temp.XXXXXX")

clone_url="https://github.com/${REPO}.git"
git clone --depth 1 "$clone_url" "$tmpdir"

for t in "${TEMPLATES[@]}"; do
  src="${tmpdir}/${t}"
  if [[ ! -d "$src" ]]; then
    echo "Error: no template directory '${t}' in ${REPO}." >&2
    list_template_hints "$tmpdir"
    exit 1
  fi

  if [[ -n "$OUT" ]]; then
    dest="$OUT"
  elif [[ -n "$PREFIX" ]]; then
    dest="${PREFIX%/}/${t}"
  else
    dest="./${t}"
  fi

  ensure_parent "$dest"

  if dir_nonempty "$dest"; then
    confirm_overwrite "$dest" || exit 1
    rm -rf "$dest"
  fi

  cp -a "$src" "$dest"
  echo "Copied '${t}' -> ${dest}"
done
