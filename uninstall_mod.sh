#!/bin/bash
# ==============================================================================
# Script de Desinstalação do Mod Exiled Kingdoms Overhaul
# ==============================================================================
set -e

if [ -z "$GAME_DIR" ]; then
    POSSIBLE_PATHS=(
        "$HOME/.local/share/Steam/steamapps/common/Exiled Kingdoms"
        "$HOME/.steam/steam/steamapps/common/Exiled Kingdoms"
        "$HOME/.steam/root/steamapps/common/Exiled Kingdoms"
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Exiled Kingdoms"
    )
    for p in "${POSSIBLE_PATHS[@]}"; do
        if [ -d "$p" ]; then
            GAME_DIR="$p"
            break
        fi
    done
fi

if [ -z "$GAME_DIR" ] || [ ! -d "$GAME_DIR" ]; then
    echo "ERRO: Diretório do Exiled Kingdoms não encontrado."
    exit 1
fi

echo "Restaurando config.json original..."
if [ -f "$GAME_DIR/config.json.bak" ]; then
    cp "$GAME_DIR/config.json.bak" "$GAME_DIR/config.json"
else
    sed -i '/"mods\/"/d' "$GAME_DIR/config.json"
fi

echo "Removendo pasta de mods e arquivos customizados..."
rm -rf "$GAME_DIR/mods"
rm -rf "$GAME_DIR/data/rules"
rm -rf "$GAME_DIR/data/sprites"

echo "O jogo retornou 100% ao estado original vanilla!"
