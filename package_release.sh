#!/bin/sh
# ==============================================================================
# Exiled Kingdoms Overhaul — Packaging & Release Script
# Builds universal distributions for Linux and Windows
# ==============================================================================
set -eu

VERSION="1.0.0"
REPO_ROOT=$(cd "$(dirname "$0")" && pwd)
RELEASE_DIR="$REPO_ROOT/release"
BUILD_TMP="$REPO_ROOT/scratch/release_tmp"

echo "===================================================================="
echo "  Gerando Pacotes de Release — Exiled Kingdoms Overhaul v$VERSION"
echo "===================================================================="

# 1. Clean and prepare directories
rm -rf "$BUILD_TMP"
mkdir -p "$RELEASE_DIR" "$BUILD_TMP"

# 2. Compile Windows Inno Setup Installer
echo "\n[1/4] Compilando instalador nativo do Windows (.exe)..."
chmod +x "$REPO_ROOT/installer/windows/build_windows_installer.sh"
"$REPO_ROOT/installer/windows/build_windows_installer.sh"

# 3. Create README.txt for releases
cat << 'EOF' > "$BUILD_TMP/README.txt"
====================================================================
           EXILED KINGDOMS OVERHAUL — GUIA DE INSTALAÇÃO
====================================================================
Versão: 1.0.0
Repositório: https://github.com/yohanhajy/exiled-kingdoms-overhaul
Autor: Exiled Kingdoms Overhaul Team

DESCRIÇÃO:
O Exiled Kingdoms Overhaul é um mod completo e não-destrutivo para a
versão Steam do Exiled Kingdoms. O arquivo original do jogo (.jar) NUNCA
é modificado — as melhorias são injetadas dinamicamente via classpath.

MELHORIAS INCLUÍDAS:
• Movimento 360° Suave e Contínuo (Adeus ao movimento travado em 8 direções)
• Correção Anatômica de Equipamentos Visuais
• Spritesheet Exclusivo de Escudos e Armaduras de Placas Coloridas
• Suporte Nativo a Steam Deck e Sistemas Linux/Windows

--------------------------------------------------------------------
INSTRUÇÕES DE INSTALAÇÃO:
--------------------------------------------------------------------

[WINDOWS]
1. Se você baixou o instalador "ExiledKingdomsOverhaul-Setup-v1.0.0.exe",
   basta dar dois cliques nele e seguir o assistente na tela.
2. A pasta do jogo na Steam será detectada automaticamente.
3. Clique em Instalar e pronto! Abra o jogo pela Steam.

[LINUX / STEAM DECK]
1. Extraia o conteúdo deste pacote em qualquer pasta.
2. Abra um terminal na pasta extraída e execute:
       ./install.sh
3. O instalador detectará automaticamente a instalação do Steam (inclusive
   Flatpak, Snap e Steam Deck) e aplicará o mod.
4. Para desinstalar a qualquer momento, execute:
       ./uninstall.sh

BOM JOGO!
====================================================================
EOF

# 4. Package Linux Distribution (tar.gz and zip)
echo "\n[2/4] Empacotando distribuição Linux..."
LINUX_PKG_DIR="$BUILD_TMP/ExiledKingdomsOverhaul-v$VERSION-Linux"
mkdir -p "$LINUX_PKG_DIR"

cp "$REPO_ROOT/installer/linux/install.sh" "$LINUX_PKG_DIR/install.sh"
cp "$REPO_ROOT/installer/linux/uninstall.sh" "$LINUX_PKG_DIR/uninstall.sh"
chmod +x "$LINUX_PKG_DIR/install.sh" "$LINUX_PKG_DIR/uninstall.sh"
cp "$BUILD_TMP/README.txt" "$LINUX_PKG_DIR/README.txt"
cp -R "$REPO_ROOT/mods" "$LINUX_PKG_DIR/mods"

# Helper function to create zip archives reliably
create_zip() {
    _zip_out="$1"
    _zip_in="$2"
    _base_dir="$3"
    if command -v zip >/dev/null 2>&1; then
        (cd "$_base_dir" && zip -qr "$_zip_out" "$_zip_in")
    elif command -v python3 >/dev/null 2>&1; then
        (cd "$_base_dir" && python3 -m zipfile -c "$_zip_out" "$_zip_in")
    elif command -v 7z >/dev/null 2>&1; then
        (cd "$_base_dir" && 7z a -tzip -bd -bso0 "$_zip_out" "$_zip_in")
    else
        echo "Aviso: Nenhuma ferramenta de zip encontrada. Ignorando $_zip_out"
    fi
}

# Create .tar.gz (standard for Linux/SteamOS)
tar -czf "$RELEASE_DIR/ExiledKingdomsOverhaul-v$VERSION-Linux.tar.gz" -C "$BUILD_TMP" "ExiledKingdomsOverhaul-v$VERSION-Linux"

# Create .zip (for users preferring zip)
create_zip "$RELEASE_DIR/ExiledKingdomsOverhaul-v$VERSION-Linux.zip" "ExiledKingdomsOverhaul-v$VERSION-Linux" "$BUILD_TMP"

# 5. Package Universal Distribution
echo "\n[3/4] Empacotando distribuição Universal..."
UNIV_PKG_DIR="$BUILD_TMP/ExiledKingdomsOverhaul-v$VERSION-Universal"
mkdir -p "$UNIV_PKG_DIR"

cp "$RELEASE_DIR/ExiledKingdomsOverhaul-Setup-v$VERSION.exe" "$UNIV_PKG_DIR/"
cp "$REPO_ROOT/installer/linux/install.sh" "$UNIV_PKG_DIR/install.sh"
cp "$REPO_ROOT/installer/linux/uninstall.sh" "$UNIV_PKG_DIR/uninstall.sh"
chmod +x "$UNIV_PKG_DIR/install.sh" "$UNIV_PKG_DIR/uninstall.sh"
cp "$BUILD_TMP/README.txt" "$UNIV_PKG_DIR/README.txt"
cp -R "$REPO_ROOT/mods" "$UNIV_PKG_DIR/mods"

create_zip "$RELEASE_DIR/ExiledKingdomsOverhaul-v$VERSION-Universal.zip" "ExiledKingdomsOverhaul-v$VERSION-Universal" "$BUILD_TMP"

# 6. Generate Checksums (SHA-256)
echo "\n[4/4] Gerando somas de verificação SHA-256..."
cd "$RELEASE_DIR"
sha256sum ExiledKingdomsOverhaul-Setup-v$VERSION.exe \
          ExiledKingdomsOverhaul-v$VERSION-Linux.tar.gz \
          ExiledKingdomsOverhaul-v$VERSION-Linux.zip \
          ExiledKingdomsOverhaul-v$VERSION-Universal.zip > SHA256SUMS.txt

# Cleanup temporary build folder
rm -rf "$BUILD_TMP"

echo "\n===================================================================="
echo "  TODOS OS PACOTES FORAM GERADOS COM SUCESSO EM release/:"
echo "===================================================================="
ls -lh "$RELEASE_DIR"
echo "===================================================================="
