#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-1313}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_DIR="$ROOT_DIR/.run"
PID_FILE="$RUN_DIR/hugo-server.pid"
STDOUT_LOG="$RUN_DIR/hugo-server.out.log"
STDERR_LOG="$RUN_DIR/hugo-server.err.log"

mkdir -p "$RUN_DIR"

if [[ -f "$PID_FILE" ]]; then
  EXISTING_PID="$(tr -d '[:space:]' < "$PID_FILE")"
  if [[ -n "$EXISTING_PID" ]] && kill -0 "$EXISTING_PID" 2>/dev/null; then
    echo "Hugo server is already running in background. PID: $EXISTING_PID"
    echo "URL: http://localhost:$PORT/"
    exit 0
  fi

  rm -f "$PID_FILE"
fi

if ! command -v hugo >/dev/null 2>&1; then
  echo "Cannot find 'hugo' in PATH. Please install Hugo or add it to PATH first." >&2
  exit 1
fi

nohup hugo server --bind 0.0.0.0 --port "$PORT" >"$STDOUT_LOG" 2>"$STDERR_LOG" < /dev/null &
PID=$!
echo "$PID" > "$PID_FILE"

echo "Hugo server started in background."
echo "PID: $PID"
echo "URL: http://localhost:$PORT/"
echo "STDOUT: $STDOUT_LOG"
echo "STDERR: $STDERR_LOG"
