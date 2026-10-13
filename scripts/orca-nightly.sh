#!/usr/bin/env bash
# Launch the OrcaSlicer nightly on Linux with the Wayland/HiDPI workarounds.
# Without them the window never appears (Debian 13, Wayland session, scale 2).
#
#   scripts/orca-nightly.sh                    # uses the newest nightly AppImage
#   ORCA_APPIMAGE=/path/to/file.AppImage scripts/orca-nightly.sh
#
# Output is saved to ~/Projects/Orcaslicer/runs/nightly-<date-time>.log.
# To stop a hung Orca: Ctrl+C in this terminal tab.
set -uo pipefail

APP="${ORCA_APPIMAGE:-$(ls -t "$HOME"/Applications/orca/OrcaSlicer_Linux_AppImage_*nightly*.AppImage 2>/dev/null | head -1)}"
[ -x "$APP" ] || { echo "Nightly AppImage not found or not executable: ${APP:-none}" >&2; exit 1; }

if pgrep -x orca-slicer >/dev/null; then
  echo "An Orca is already running (pgrep -a orca). Quit it, or: pkill -f orca-slicer" >&2
  exit 1
fi

RUNS="$HOME/Projects/Orcaslicer/runs"; mkdir -p "$RUNS"
LOG="$RUNS/nightly-$(date +%Y%m%d-%H%M%S).log"
echo "Launching: $APP"
echo "Log:       $LOG"

export GDK_BACKEND=x11
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export WEBKIT_DISABLE_COMPOSITING_MODE=1
"$APP" "$@" 2>&1 | tee "$LOG"
echo "Orca exited with code: ${PIPESTATUS[0]}"
