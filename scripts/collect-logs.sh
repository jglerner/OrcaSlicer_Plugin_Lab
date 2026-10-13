#!/usr/bin/env bash
# Copy a test run's logs into logs/<linux|macos>/<date-time>/ inside this repository.
#
#   scripts/collect-logs.sh                 # copy the logs
#   scripts/collect-logs.sh "short note"    # and save the note in NOTE.txt
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
case "$(uname -s)" in
  Linux)  OS=linux; DEFAULT_DATA="$HOME/.config/OrcaSlicer" ;;
  Darwin) OS=macos; DEFAULT_DATA="$HOME/Library/Application Support/OrcaSlicer" ;;
  *) echo "Unsupported OS" >&2; exit 1 ;;
esac
DATA="${ORCA_DATA_DIR:-$DEFAULT_DATA}"
OUT="$REPO/logs/$OS/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

cp "$DATA/orca_plugins/SupportFins/support_fins_log.jsonl" "$OUT/" 2>/dev/null \
  || echo "(no support_fins_log.jsonl yet)"
# only the 3 most recent Python logs
ls -t "$DATA"/log/python_*.log 2>/dev/null | head -3 | while read -r f; do cp "$f" "$OUT/"; done || true
cp "$DATA/orca_plugins/config.json" "$OUT/orca_plugins-config.json" 2>/dev/null || true

{
  echo "date: $(date)"
  echo "system: $(uname -srm)"
  if [ "$OS" = macos ]; then sw_vers 2>/dev/null || true; fi
  if [ -n "${1:-}" ]; then echo "note: $1"; fi
} > "$OUT/NOTE.txt"

echo "Logs copied to: $OUT"
echo "Check for personal data before committing."
