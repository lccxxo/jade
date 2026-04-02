#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_DIR="$ROOT_DIR/.run"
PID_FILE="$RUN_DIR/hugo-server.pid"

if [[ ! -f "$PID_FILE" ]]; then
  echo "No running Hugo server PID file found."
  exit 0
fi

PID="$(tr -d '[:space:]' < "$PID_FILE")"
if [[ -z "$PID" ]]; then
  rm -f "$PID_FILE"
  echo "PID file was empty and has been cleaned up."
  exit 0
fi

if ! kill -0 "$PID" 2>/dev/null; then
  rm -f "$PID_FILE"
  echo "Hugo server process was not running. PID file has been cleaned up."
  exit 0
fi

kill "$PID"
rm -f "$PID_FILE"

echo "Hugo server stopped. PID: $PID"
