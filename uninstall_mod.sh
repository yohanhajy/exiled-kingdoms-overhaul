#!/bin/bash
# ==============================================================================
# Script de Desinstalação do Mod de Equipamentos Visíveis
# ==============================================================================
GAME_DIR="/home/yhn/.local/share/Steam/steamapps/common/Exiled Kingdoms"

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
