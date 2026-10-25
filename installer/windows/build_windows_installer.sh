#!/bin/sh
# ==============================================================================
# Exiled Kingdoms Overhaul — Windows Installer Build Helper
# Compiles installer/windows/setup.iss using ISCC (Inno Setup Compiler)
# Supports native Windows environment and Linux via Wine
# ==============================================================================
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
ISS_FILE="$SCRIPT_DIR/setup.iss"

mkdir -p "$REPO_ROOT/release"

if command -v iscc >/dev/null 2>&1; then
    echo "Usando ISCC nativo..."
    iscc "$ISS_FILE"
elif [ -f "$REPO_ROOT/scratch/innosetup/app/ISCC.exe" ] && command -v wine >/dev/null 2>&1; then
    echo "Usando ISCC via Wine..."
    WINE_ISS=$(printf '%s' "$ISS_FILE" | sed -e 's/^\//Z:\\/' -e 's/\//\\/g')
    wine "$REPO_ROOT/scratch/innosetup/app/ISCC.exe" "$WINE_ISS"
else
    echo "ERRO: O compilador Inno Setup (ISCC) não foi encontrado no sistema nem em scratch/innosetup/app." >&2
    exit 1
fi

echo "Compilação do instalador Windows concluída com sucesso em $REPO_ROOT/release!"
