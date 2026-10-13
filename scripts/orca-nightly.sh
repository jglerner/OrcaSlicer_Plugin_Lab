#!/usr/bin/env bash
# Abre a OrcaSlicer nightly no Linux com as correções para Wayland/HiDPI.
# Sem elas a janela não abre (Debian 13, sessão Wayland, escala 2).
#
#   scripts/orca-nightly.sh                    # usa o AppImage nightly mais recente
#   ORCA_APPIMAGE=/caminho/arquivo.AppImage scripts/orca-nightly.sh
#
# A saída fica em ~/Projects/Orcaslicer/runs/nightly-<data-hora>.log.
# Para encerrar um Orca travado: Ctrl+C nesta aba.
set -uo pipefail

APP="${ORCA_APPIMAGE:-$(ls -t "$HOME"/Applications/orca/OrcaSlicer_Linux_AppImage_*nightly*.AppImage 2>/dev/null | head -1)}"
[ -x "$APP" ] || { echo "AppImage nightly não encontrado/executável: ${APP:-nenhum}" >&2; exit 1; }

if pgrep -x orca-slicer >/dev/null; then
  echo "Já existe um Orca rodando (pgrep -a orca). Feche-o ou: pkill -f orca-slicer" >&2
  exit 1
fi

RUNS="$HOME/Projects/Orcaslicer/runs"; mkdir -p "$RUNS"
LOG="$RUNS/nightly-$(date +%Y%m%d-%H%M%S).log"
echo "Abrindo: $APP"
echo "Log:     $LOG"

export GDK_BACKEND=x11
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export WEBKIT_DISABLE_COMPOSITING_MODE=1
"$APP" "$@" 2>&1 | tee "$LOG"
echo "Orca saiu com código: ${PIPESTATUS[0]}"
