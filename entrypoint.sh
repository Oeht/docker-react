#!/bin/bash
set -euo pipefail

APP_DIR="/react-docker"

# --- 1) Scaffold ONLY in a temp dir, then merge ---
if [ ! -f "$APP_DIR/package.json" ]; then
  echo "[init] Scaffolding CRA in temp..."
  TMP_PARENT="$(mktemp -d)"
  TMP_DIR="$TMP_PARENT/app"
  mkdir -p "$TMP_DIR"

  # safe name (lowercase) so npm name rules won't fail
  npx create-react-app "$TMP_DIR" --template cra-template

  # copy root files (exclude src/public/node_modules to avoid conflicts with mounts)
  rsync -a --exclude src --exclude public --exclude node_modules "$TMP_DIR"/ "$APP_DIR"/

  # seed src/public ONLY if missing or empty
  for d in src public; do
    if [ ! -d "$APP_DIR/$d" ] || [ -z "$(ls -A "$APP_DIR/$d" 2>/dev/null || true)" ]; then
      echo "[init] Seeding $d/"
      rsync -a "$TMP_DIR/$d/" "$APP_DIR/$d/"
    else
      echo "[init] Keeping existing $d/ (not overwriting)"
    fi
  done

  rm -rf "$TMP_PARENT"
fi

# --- 2) Ensure deps (react-scripts must exist) ---
cd "$APP_DIR"
if [ ! -x node_modules/.bin/react-scripts ]; then
  echo "[deps] Installing dependencies..."
  npm ci || npm install
fi

# --- 3) Start dev server from the APP ROOT (no --prefix!) ---
echo "[start] CRA dev server on 0.0.0.0:3000"
exec npm start -- --host 0.0.0.0 --port 3000
