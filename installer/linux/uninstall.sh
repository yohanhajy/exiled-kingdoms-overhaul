#!/bin/sh
# ==============================================================================
# Exiled Kingdoms Overhaul — Linux Uninstaller (POSIX Compliant)
# ==============================================================================
set -eu

if [ -t 1 ]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_GREEN="\033[32m"
    C_CYAN="\033[36m"
    C_YELLOW="\033[33m"
    C_RED="\033[31m"
else
    C_RESET=""
    C_BOLD=""
    C_GREEN=""
    C_CYAN=""
    C_YELLOW=""
    C_RED=""
fi

log_info() {
    printf "${C_CYAN}${C_BOLD}[INFO]${C_RESET} %s\n" "$1"
}

log_success() {
    printf "${C_GREEN}${C_BOLD}[SUCESSO]${C_RESET} %s\n" "$1"
}

log_warn() {
    printf "${C_YELLOW}${C_BOLD}[AVISO]${C_RESET} %s\n" "$1"
}

printf "\n"
printf "${C_BOLD}====================================================================${C_RESET}\n"
printf "${C_CYAN}${C_BOLD}            Exiled Kingdoms Overhaul — Desinstalador Linux           ${C_RESET}\n"
printf "${C_BOLD}====================================================================${C_RESET}\n\n"

TARGET_GAME_DIR=""

# 1. Priority 1: Command line argument (e.g. ./uninstall.sh "/path/to/game")
if [ $# -gt 0 ] && [ -n "$1" ]; then
    arg_path="$1"
    case "$arg_path" in
        "~"*) arg_path="$HOME${arg_path#\~}" ;;
    esac
    if [ -f "$arg_path/exiledkingdoms.jar" ]; then
        TARGET_GAME_DIR="$arg_path"
    fi
fi

# 2. Priority 2: Environment variable EXILED_KINGDOMS_DIR
if [ -z "$TARGET_GAME_DIR" ] && [ -n "${EXILED_KINGDOMS_DIR:-}" ]; then
    env_path="$EXILED_KINGDOMS_DIR"
    case "$env_path" in
        "~"*) env_path="$HOME${env_path#\~}" ;;
    esac
    if [ -f "$env_path/exiledkingdoms.jar" ]; then
        TARGET_GAME_DIR="$env_path"
    fi
fi

# 3. Priority 3: Current directory
if [ -z "$TARGET_GAME_DIR" ] && [ -f "./exiledkingdoms.jar" ] && [ -f "./config.json" ]; then
    TARGET_GAME_DIR=$(pwd)
fi

# 4. Priority 4: Search standard Steam roots and libraryfolders.vdf
if [ -z "$TARGET_GAME_DIR" ]; then
    CANDIDATE_ROOTS="
$HOME/.local/share/Steam
$HOME/.steam/steam
$HOME/.steam/root
$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam
$HOME/.var/app/com.valvesoftware.Steam/.steam/steam
$HOME/snap/steam/common/.local/share/Steam
/home/deck/.local/share/Steam
"
    for root in $CANDIDATE_ROOTS; do
        if [ -d "$root" ]; then
            direct_check="$root/steamapps/common/Exiled Kingdoms"
            if [ -f "$direct_check/exiledkingdoms.jar" ]; then
                TARGET_GAME_DIR="$direct_check"
                break
            fi
            vdf_file="$root/steamapps/libraryfolders.vdf"
            if [ -f "$vdf_file" ]; then
                vdf_paths=$(sed -n 's/^[[:space:]]*"path"[[:space:]]*"\([^"]*\)".*/\1/p' "$vdf_file" 2>/dev/null || true)
                for lib in $vdf_paths; do
                    lib_check="$lib/steamapps/common/Exiled Kingdoms"
                    if [ -f "$lib_check/exiledkingdoms.jar" ]; then
                        TARGET_GAME_DIR="$lib_check"
                        break 2
                    fi
                done
            fi
        fi
    done
fi

if [ -z "$TARGET_GAME_DIR" ] || [ ! -d "$TARGET_GAME_DIR" ]; then
    log_warn "Diretório do jogo não encontrado automaticamente."
    printf "${C_BOLD}Digite o caminho da pasta do Exiled Kingdoms:${C_RESET} "
    read -r TARGET_GAME_DIR
    TARGET_GAME_DIR=$(printf '%s' "$TARGET_GAME_DIR" | sed -e 's/^["'\'' ]*//' -e 's/["'\'' ]*$//')
    case "$TARGET_GAME_DIR" in
        "~"*) TARGET_GAME_DIR="$HOME${TARGET_GAME_DIR#\~}" ;;
    esac
fi

log_info "Desinstalando de: $TARGET_GAME_DIR"

# 1. Remove mods/ directory
if [ -d "$TARGET_GAME_DIR/mods" ]; then
    rm -rf "$TARGET_GAME_DIR/mods"
    log_success "Diretório mods/ removido."
else
    log_info "Diretório mods/ já não estava presente."
fi

# 2. Restore config.json
if [ -f "$TARGET_GAME_DIR/config.json.bak" ]; then
    cp -p "$TARGET_GAME_DIR/config.json.bak" "$TARGET_GAME_DIR/config.json"
    rm -f "$TARGET_GAME_DIR/config.json.bak"
    log_success "config.json restaurado a partir do backup original."
else
    # Strip "mods/", from classPath via awk if backup is not available
    if [ -f "$TARGET_GAME_DIR/config.json" ]; then
        TEMP_CONF="$TARGET_GAME_DIR/config.json.tmp.$$"
        awk '!/"mods\/"/' "$TARGET_GAME_DIR/config.json" > "$TEMP_CONF"
        mv "$TEMP_CONF" "$TARGET_GAME_DIR/config.json"
        log_info "Entrada 'mods/' removida de config.json."
    fi
fi

printf "\n"
printf "${C_GREEN}${C_BOLD}O Exiled Kingdoms foi revertido para a versão original com sucesso!${C_RESET}\n\n"
