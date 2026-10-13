#!/usr/bin/env bash
# Copia os logs de um teste para logs/<linux|macos>/<data-hora>/ dentro deste repositório.
#
#   scripts/collect-logs.sh                 # copia os logs
#   scripts/collect-logs.sh "nota curta"    # e grava a nota em NOTA.txt
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
case "$(uname -s)" in
  Linux)  OS=linux; DEFAULT_DATA="$HOME/.config/OrcaSlicer" ;;
  Darwin) OS=macos; DEFAULT_DATA="$HOME/Library/Application Support/OrcaSlicer" ;;
  *) echo "Sistema não suportado" >&2; exit 1 ;;
esac
DATA="${ORCA_DATA_DIR:-$DEFAULT_DATA}"
OUT="$REPO/logs/$OS/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

cp "$DATA/orca_plugins/SupportFins/support_fins_log.jsonl" "$OUT/" 2>/dev/null \
  || echo "(sem support_fins_log.jsonl ainda)"
# só os 3 logs Python mais recentes
ls -t "$DATA"/log/python_*.log 2>/dev/null | head -3 | while read -r f; do cp "$f" "$OUT/"; done || true
cp "$DATA/orca_plugins/config.json" "$OUT/orca_plugins-config.json" 2>/dev/null || true

{
  echo "data: $(date)"
  echo "sistema: $(uname -srm)"
  if [ "$OS" = macos ]; then sw_vers 2>/dev/null || true; fi
  if [ -n "${1:-}" ]; then echo "nota: $1"; fi
} > "$OUT/NOTA.txt"

echo "Logs copiados para: $OUT"
echo "Confira se não há dados pessoais antes de dar commit."
