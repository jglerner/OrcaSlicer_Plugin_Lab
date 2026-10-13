#!/usr/bin/env bash
# Instala o plugin Support Fins no OrcaSlicer (nightly). Mesmo script para Linux e macOS.
#
#   scripts/install-support-fins.sh            # backup + download + instalação
#   ORCA_DATA_DIR=/outra/pasta scripts/install-support-fins.sh
#   SKIP_BACKUP=1 scripts/install-support-fins.sh
#   PLUGIN_FILE=plugins/support-fins/support_fins_orca-<sha8>.py scripts/install-support-fins.sh
#                                 # usa um arquivo local em vez de baixar (mesmo build do outro SO)
#
# Feche o OrcaSlicer antes de rodar.
set -euo pipefail

PLUGIN_URL="https://github.com/gittrahan/support-fins/releases/download/plugins-latest/support_fins_orca.py"
WORK="${ORCA_WORK_DIR:-$HOME/Projects/Orcaslicer}"

case "$(uname -s)" in
  Linux)  DEFAULT_DATA="$HOME/.config/OrcaSlicer" ;;
  Darwin) DEFAULT_DATA="$HOME/Library/Application Support/OrcaSlicer" ;;
  *) echo "Sistema não suportado: $(uname -s)" >&2; exit 1 ;;
esac
DATA="${ORCA_DATA_DIR:-$DEFAULT_DATA}"

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

if pgrep -i "^orca-?slicer$" >/dev/null 2>&1; then
  echo "O OrcaSlicer parece estar aberto. Feche-o e rode de novo." >&2
  exit 1
fi

if [ ! -d "$DATA" ]; then
  echo "Pasta de configuração não encontrada: $DATA" >&2
  echo "Abra o Orca uma vez ou indique outra pasta com ORCA_DATA_DIR=..." >&2
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$WORK/backups" "$WORK/downloads"

# 1. Backup da configuração (a nightly e a 2.4.2 usam a mesma pasta)
if [ "${SKIP_BACKUP:-0}" != "1" ]; then
  BK="$WORK/backups/OrcaSlicer-$STAMP.tar.gz"
  echo "Backup: $DATA -> $BK"
  tar -czf "$BK" -C "$(dirname "$DATA")" "$(basename "$DATA")"
fi

# 2. Download (ou arquivo local) com registro do hash
DL="$WORK/downloads/support_fins_orca-$STAMP.py"
if [ -n "${PLUGIN_FILE:-}" ]; then
  echo "Usando arquivo local: $PLUGIN_FILE"
  cp "$PLUGIN_FILE" "$DL"
else
  echo "Baixando $PLUGIN_URL"
  curl -fL --retry 3 -o "$DL" "$PLUGIN_URL"
fi
head -c 20 "$DL" | grep -q '^# /// script' || { echo "Arquivo baixado não parece o plugin." >&2; exit 1; }
VERSION="$(sed -n 's/^# version = "\(.*\)"/\1/p' "$DL" | head -1)"
HASH="$(sha256 "$DL")"
echo "$STAMP  $HASH  versão=$VERSION  $(uname -s)" >> "$WORK/downloads/SHA256SUMS.txt"

# 3. Instalação
DEST="$DATA/orca_plugins/SupportFins"
mkdir -p "$DEST"
cp "$DL" "$DEST/support_fins_orca.py"

echo
echo "Instalado: $DEST/support_fins_orca.py"
echo "  versão do plugin: $VERSION"
echo "  sha256:           $HASH"
echo
echo "Próximo passo: abra o OrcaSlicer NIGHTLY > Plugins > marque 'Support Fins'."
