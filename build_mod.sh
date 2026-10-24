#!/bin/bash
# ==============================================================================
# Build Script: Visible Weapons & Shields Mod for Exiled Kingdoms (Steam Linux)
# ==============================================================================
set -e

PROJECT_DIR="/home/yhn/Projetos/exiled-kingdoms-mod"
GAME_DIR="/home/yhn/.local/share/Steam/steamapps/common/Exiled Kingdoms"
JAR_PATH="$GAME_DIR/exiledkingdoms.jar"
MODS_DIR="$PROJECT_DIR/mods"
GAME_MODS_DIR="$GAME_DIR/mods"

echo "[1/5] Preparando diretórios de build..."
mkdir -p "$MODS_DIR"
mkdir -p "$PROJECT_DIR/scratch"
mkdir -p "$GAME_MODS_DIR"

echo "[2/5] Compilando classes do mod (EquipmentVisuals, MovementPatch)..."
javac -source 8 -target 8 -cp "$JAR_PATH" -d "$MODS_DIR" "$PROJECT_DIR"/src/net/fdgames/mods/*.java

# Converter major version para 51 (Java 7 compatível com o JRE do jogo)
python3 -c '
import glob
for p in glob.glob("'"$MODS_DIR"'/net/fdgames/mods/*.class"):
    with open(p, "rb") as f:
        data = bytearray(f.read())
    data[7] = 51
    with open(p, "wb") as f:
        f.write(data)
'

echo "[3/5] Aplicando bytecode patch em Player.class, NPC.class e P.class com Javassist..."
cat << 'EOF' > "$PROJECT_DIR/scratch/ModPatcher.java"
import javassist.*;

public class ModPatcher {
    public static void main(String[] args) throws Exception {
        String jarPath = "/home/yhn/.local/share/Steam/steamapps/common/Exiled Kingdoms/exiledkingdoms.jar";
        String modsPath = "/home/yhn/Projetos/exiled-kingdoms-mod/mods";

        ClassPool pool = ClassPool.getDefault();
        pool.appendClassPath(modsPath);
        pool.appendClassPath(jarPath);

        // 1. Patch Player.class (Armas e Armaduras Visíveis)
        CtClass ctPlayer = pool.get("net.fdgames.GameEntities.Final.Player");
        CtMethod mPlayerAc = ctPlayer.getDeclaredMethod("ac");
        mPlayerAc.insertAfter("net.fdgames.mods.EquipmentVisuals.apply(this);");
        ctPlayer.writeFile(modsPath);

        // 2. Patch NPC.class (Companheiros com Equipamentos Visíveis)
        CtClass ctNpc = pool.get("net.fdgames.GameEntities.Final.NPC");
        CtMethod mNpcAc = ctNpc.getDeclaredMethod("ac");
        mNpcAc.insertAfter("net.fdgames.mods.EquipmentVisuals.apply(this);");
        ctNpc.writeFile(modsPath);

        // 3. Patch P.class (Movimentação Isométrica Uniforme do Jogador 360 Graus)
        CtClass ctP = pool.get("net.fdgames.UI.P");
        CtMethod mPa = ctP.getDeclaredMethod("a", new CtClass[] { CtClass.floatType, CtClass.floatType });
        mPa.setBody("{ net.fdgames.mods.MovementPatch.updateMovement($1, $2); }");
        ctP.writeFile(modsPath);

        // 4. Patch Character.class (Movimentação Isométrica de Inimigos, Monstros e Companheiros)
        CtClass ctChar = pool.get("net.fdgames.GameEntities.Character");
        CtMethod mCharH = ctChar.getDeclaredMethod("H");
        mCharH.setBody("{ net.fdgames.mods.MovementPatch.updateCharacterMovement(this); }");
        ctChar.writeFile(modsPath);
        
        System.out.println("Bytecode patches executados com sucesso.");
    }
}
EOF

javac -cp "$PROJECT_DIR/tools/javassist.jar:$JAR_PATH" "$PROJECT_DIR/scratch/ModPatcher.java"
java -cp "$PROJECT_DIR/scratch:$PROJECT_DIR/tools/javassist.jar:$JAR_PATH" ModPatcher

echo "[4/5] Ajustando versão de classe dos patches para Java 7..."
python3 -c '
for rel in [
    "net/fdgames/GameEntities/Final/Player.class",
    "net/fdgames/GameEntities/Final/NPC.class",
    "net/fdgames/UI/P.class",
    "net/fdgames/GameEntities/Character.class"
]:
    p = "'"$MODS_DIR"'/" + rel
    with open(p, "rb") as f:
        d = bytearray(f.read())
    d[7] = 51
    with open(p, "wb") as f:
        f.write(d)
'

echo "[5/5] Sincronizando arquivos compilados com o jogo na Steam..."
cp -r "$MODS_DIR/"* "$GAME_MODS_DIR/"
if [ -d "$MODS_DIR/data" ]; then
    cp -r "$MODS_DIR/data" "$GAME_DIR/"
fi

# Configura o config.json se ainda não estiver configurado
if ! grep -q '"mods/"' "$GAME_DIR/config.json"; then
    echo "Atualizando config.json da Steam para carregar mods/..."
    cp "$GAME_DIR/config.json" "$GAME_DIR/config.json.bak"
    sed -i 's|"classPath": \[|"classPath": \[\n    "mods/",|' "$GAME_DIR/config.json"
fi

echo "=========================================================="
echo " MOD DE EQUIPAMENTOS VISÍVEIS INSTALADO COM SUCESSO!"
echo " Inicie o Exiled Kingdoms na Steam para jogar."
echo "=========================================================="
