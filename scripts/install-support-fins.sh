#!/usr/bin/env bash
# Install the Support Fins plugin into OrcaSlicer (nightly). Same script for Linux and macOS.
#
#   scripts/install-support-fins.sh            # backup + download + install
#   ORCA_DATA_DIR=/other/folder scripts/install-support-fins.sh
#   SKIP_BACKUP=1 scripts/install-support-fins.sh
#   PLUGIN_FILE=plugins/support-fins/support_fins_orca-<sha8>.py scripts/install-support-fins.sh
#                                 # use a local file instead of downloading (same build as the other OS)
#
# Close OrcaSlicer before running.
set -euo pipefail

PLUGIN_URL="https://github.com/gittrahan/support-fins/releases/download/plugins-latest/support_fins_orca.py"
WORK="${ORCA_WORK_DIR:-$HOME/Projects/Orcaslicer}"

case "$(uname -s)" in
  Linux)  DEFAULT_DATA="$HOME/.config/OrcaSlicer" ;;
  Darwin) DEFAULT_DATA="$HOME/Library/Application Support/OrcaSlicer" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
DATA="${ORCA_DATA_DIR:-$DEFAULT_DATA}"

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

if pgrep -i "^orca-?slicer$" >/dev/null 2>&1; then
  echo "OrcaSlicer seems to be running. Quit it and run this again." >&2
  exit 1
fi

if [ ! -d "$DATA" ]; then
  echo "Configuration folder not found: $DATA" >&2
  echo "Open Orca once, or point to another folder with ORCA_DATA_DIR=..." >&2
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$WORK/backups" "$WORK/downloads"

# 1. Back up the configuration (nightly and stable share the same folder)
if [ "${SKIP_BACKUP:-0}" != "1" ]; then
  BK="$WORK/backups/OrcaSlicer-$STAMP.tar.gz"
  echo "Backup: $DATA -> $BK"
  tar -czf "$BK" -C "$(dirname "$DATA")" "$(basename "$DATA")"
fi

# 2. Download (or local file), recording the hash
DL="$WORK/downloads/support_fins_orca-$STAMP.py"
if [ -n "${PLUGIN_FILE:-}" ]; then
  echo "Using local file: $PLUGIN_FILE"
  cp "$PLUGIN_FILE" "$DL"
else
  echo "Downloading $PLUGIN_URL"
  curl -fL --retry 3 -o "$DL" "$PLUGIN_URL"
fi
head -c 20 "$DL" | grep -q '^# /// script' || { echo "The file does not look like the plugin." >&2; exit 1; }
VERSION="$(sed -n 's/^# version = "\(.*\)"/\1/p' "$DL" | head -1)"
HASH="$(sha256 "$DL")"
echo "$STAMP  $HASH  version=$VERSION  $(uname -s)" >> "$WORK/downloads/SHA256SUMS.txt"

# 3. Install
DEST="$DATA/orca_plugins/SupportFins"
mkdir -p "$DEST"
cp "$DL" "$DEST/support_fins_orca.py"

echo
echo "Installed: $DEST/support_fins_orca.py"
echo "  plugin version: $VERSION"
echo "  sha256:         $HASH"
echo
echo "Next: open the OrcaSlicer NIGHTLY > Plugins > tick 'Support Fins'."
