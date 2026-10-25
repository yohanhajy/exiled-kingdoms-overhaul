#!/bin/sh
# ==============================================================================
# Exiled Kingdoms Overhaul — Universal Linux Installer (POSIX Compliant)
# Compatible with Ubuntu, Debian, Fedora, Arch, openSUSE, Void, Alpine, SteamOS
# Zero root/sudo required. Zero build tools required.
# ==============================================================================
set -eu

# Color palette (POSIX tty check)
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

log_error() {
    printf "${C_RED}${C_BOLD}[ERRO]${C_RESET} %s\n" "$1" >&2
}

printf "\n"
printf "${C_BOLD}====================================================================${C_RESET}\n"
printf "${C_CYAN}${C_BOLD}             Exiled Kingdoms Overhaul — Instalador Linux             ${C_RESET}\n"
printf "${C_BOLD}====================================================================${C_RESET}\n\n"

# 1. Locate the source 'mods' directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SOURCE_MODS=""

if [ -d "$SCRIPT_DIR/mods" ]; then
    SOURCE_MODS="$SCRIPT_DIR/mods"
elif [ -d "$SCRIPT_DIR/../../mods" ]; then
    SOURCE_MODS=$(cd "$SCRIPT_DIR/../../mods" && pwd)
elif [ -d "./mods" ]; then
    SOURCE_MODS=$(pwd)/mods
fi

if [ -z "$SOURCE_MODS" ] || [ ! -d "$SOURCE_MODS" ]; then
    log_error "Diretório de conteúdo 'mods/' não foi encontrado no instalador!"
    log_error "Certifique-se de extrair todos os arquivos do arquivo de release antes de executar."
    exit 1
fi

log_info "Conteúdo do mod localizado em: $SOURCE_MODS"

# 2. Detect Exiled Kingdoms Steam installation
TARGET_GAME_DIR=""

# 2a. Priority 1: Command line argument (e.g. ./install.sh "/path/to/game")
if [ $# -gt 0 ] && [ -n "$1" ]; then
    arg_path="$1"
    case "$arg_path" in
        "~"*) arg_path="$HOME${arg_path#\~}" ;;
    esac
    if [ -f "$arg_path/exiledkingdoms.jar" ] && [ -f "$arg_path/config.json" ]; then
        TARGET_GAME_DIR="$arg_path"
        log_info "Diretório especificado via argumento: $TARGET_GAME_DIR"
    else
        log_error "O caminho especificado via argumento não contém 'exiledkingdoms.jar' e 'config.json': $arg_path"
        exit 1
    fi
fi

# 2b. Priority 2: Environment variable EXILED_KINGDOMS_DIR
if [ -z "$TARGET_GAME_DIR" ] && [ -n "${EXILED_KINGDOMS_DIR:-}" ]; then
    env_path="$EXILED_KINGDOMS_DIR"
    case "$env_path" in
        "~"*) env_path="$HOME${env_path#\~}" ;;
    esac
    if [ -f "$env_path/exiledkingdoms.jar" ] && [ -f "$env_path/config.json" ]; then
        TARGET_GAME_DIR="$env_path"
        log_info "Diretório detectado via EXILED_KINGDOMS_DIR: $TARGET_GAME_DIR"
    fi
fi

# 2c. Priority 3: Current directory
if [ -z "$TARGET_GAME_DIR" ] && [ -f "./exiledkingdoms.jar" ] && [ -f "./config.json" ]; then
    TARGET_GAME_DIR=$(pwd)
fi

# 2d. Priority 4: Search standard Steam roots and libraryfolders.vdf
if [ -z "$TARGET_GAME_DIR" ]; then
    log_info "Procurando diretório de instalação do Exiled Kingdoms na Steam..."
    
    CANDIDATE_ROOTS="
$HOME/.local/share/Steam
$HOME/.steam/steam
$HOME/.steam/root
$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam
$HOME/.var/app/com.valvesoftware.Steam/.steam/steam
$HOME/snap/steam/common/.local/share/Steam
/home/deck/.local/share/Steam
"

    # 2a. Direct search in common Steam roots
    for root in $CANDIDATE_ROOTS; do
        if [ -d "$root" ]; then
            direct_check="$root/steamapps/common/Exiled Kingdoms"
            if [ -f "$direct_check/exiledkingdoms.jar" ] && [ -f "$direct_check/config.json" ]; then
                TARGET_GAME_DIR="$direct_check"
                break
            fi
            
            # 2b. Parse steamapps/libraryfolders.vdf for extra library paths
            vdf_file="$root/steamapps/libraryfolders.vdf"
            if [ -f "$vdf_file" ]; then
                # Extract all paths cleanly using POSIX sed
                vdf_paths=$(sed -n 's/^[[:space:]]*"path"[[:space:]]*"\([^"]*\)".*/\1/p' "$vdf_file" 2>/dev/null || true)
                for lib in $vdf_paths; do
                    lib_check="$lib/steamapps/common/Exiled Kingdoms"
                    if [ -f "$lib_check/exiledkingdoms.jar" ] && [ -f "$lib_check/config.json" ]; then
                        TARGET_GAME_DIR="$lib_check"
                        break 2
                    fi
                done
            fi
        fi
    done
fi

# 3. Fallback prompt if auto-detection failed
if [ -z "$TARGET_GAME_DIR" ]; then
    log_warn "O jogo não foi detectado automaticamente nos caminhos padrão da Steam."
    printf "${C_BOLD}Por favor, digite o caminho completo da pasta do Exiled Kingdoms:${C_RESET} "
    read -r manual_path
    
    # Strip any surrounding quotes
    manual_path=$(printf '%s' "$manual_path" | sed -e 's/^["'\'' ]*//' -e 's/["'\'' ]*$//')
    
    # Expand tilde if present
    case "$manual_path" in
        "~"*) manual_path="$HOME${manual_path#\~}" ;;
    esac
    
    if [ -f "$manual_path/exiledkingdoms.jar" ] && [ -f "$manual_path/config.json" ]; then
        TARGET_GAME_DIR="$manual_path"
    else
        log_error "O caminho informado não contém 'exiledkingdoms.jar' e 'config.json'."
        log_error "Instalação abortada."
        exit 1
    fi
fi

log_success "Diretório do jogo validado: $TARGET_GAME_DIR"

# 4. Backup config.json if not already backed up
CONFIG_FILE="$TARGET_GAME_DIR/config.json"
BACKUP_FILE="$TARGET_GAME_DIR/config.json.bak"

if [ ! -f "$BACKUP_FILE" ]; then
    log_info "Criando backup de segurança: $BACKUP_FILE"
    cp -p "$CONFIG_FILE" "$BACKUP_FILE"
else
    log_info "Backup original já existente em: $BACKUP_FILE (preservado)"
fi

# 5. Patch config.json classpath
if grep -q '"mods/"' "$CONFIG_FILE"; then
    log_info "'mods/' já está registrado no classpath de config.json."
else
    log_info "Injetando 'mods/' no classpath de config.json..."
    TEMP_CONFIG="$TARGET_GAME_DIR/config.json.tmp.$$"
    
    # Use POSIX awk for safe, standard JSON classPath injection
    awk '
        BEGIN { injected = 0 }
        /"exiledkingdoms.jar"/ && !injected {
            print "    \"mods/\",";
            injected = 1;
        }
        { print }
    ' "$CONFIG_FILE" > "$TEMP_CONFIG"
    
    mv "$TEMP_CONFIG" "$CONFIG_FILE"
    log_success "Classpath atualizado com sucesso."
fi

# 6. Copy mods directory into game directory
log_info "Copiando arquivos do mod para $TARGET_GAME_DIR/mods..."
mkdir -p "$TARGET_GAME_DIR/mods"
cp -R "$SOURCE_MODS/"* "$TARGET_GAME_DIR/mods/"

# Ensure correct file permissions for user
chmod -R u=rwX,go=rX "$TARGET_GAME_DIR/mods"
log_success "Arquivos do mod copiados com sucesso."

# 7. Install self-contained uninstaller in game directory
UNINSTALLER_SRC="$SCRIPT_DIR/uninstall.sh"
if [ ! -f "$UNINSTALLER_SRC" ]; then
    UNINSTALLER_SRC="$SCRIPT_DIR/../../uninstall_mod.sh"
fi

if [ -f "$UNINSTALLER_SRC" ]; then
    cp -p "$UNINSTALLER_SRC" "$TARGET_GAME_DIR/uninstall_mod.sh"
    chmod +x "$TARGET_GAME_DIR/uninstall_mod.sh"
    log_info "Desinstalador local instalado em: $TARGET_GAME_DIR/uninstall_mod.sh"
fi

printf "\n"
printf "${C_GREEN}${C_BOLD}====================================================================${C_RESET}\n"
printf "${C_GREEN}${C_BOLD}   INSTALAÇÃO CONCLUÍDA COM SUCESSO!                              ${C_RESET}\n"
printf "${C_BOLD}   O mod foi injetado sem alterar o arquivo original do jogo.        ${C_RESET}\n"
printf "${C_BOLD}   Você já pode abrir o Exiled Kingdoms diretamente pela Steam!    ${C_RESET}\n"
printf "${C_GREEN}${C_BOLD}====================================================================${C_RESET}\n\n"
