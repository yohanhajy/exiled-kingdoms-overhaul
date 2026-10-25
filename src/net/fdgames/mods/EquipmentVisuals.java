package net.fdgames.mods;

import com.badlogic.gdx.utils.Array;
import net.fdgames.GameEntities.Character;
import net.fdgames.GameEntities.CharacterSheet.CharacterInventory;
import net.fdgames.assets.GameAssets;

public class EquipmentVisuals {

    public static void apply(Character character) {
        if (character == null || character.sheet == null || character.sheet.inventory == null) {
            return;
        }
        if (character.spriteIndex == null || character.spriteIndex.b == 0) {
            return;
        }

        String gender = character.c(); // "male" ou "female"
        CharacterInventory inv = character.sheet.inventory;

        // 1. Arma na mão principal (slot_mainhand)
        String mainhand = inv.m();
        if (mainhand != null && !mainhand.isEmpty()) {
            String assetName = "composite/" + gender + "_mainhand_" + mainhand;
            int id = getOrLoadAsset(assetName);
            if (id != -1) {
                character.spriteIndex.a(Integer.valueOf(id));
            }
        }

        // 2. Mão secundária: Escudo OU Empunhadura Visual de Duas Mãos
        boolean isTwoHanded = (character.sheet.g() != null && character.sheet.g().twohanded);
        if (!isTwoHanded) {
            // Arma de uma mão: renderiza escudo ou arma secundária se equipada
            String offhand = inv.n();
            if (offhand != null && !offhand.isEmpty()) {
                String assetName = "composite/" + gender + "_offhand_" + offhand;
                int id = getOrLoadAsset(assetName);
                if (id != -1) {
                    character.spriteIndex.a(Integer.valueOf(id));
                }
            }
        } else if (mainhand != null && !mainhand.isEmpty()) {
            // Arma de duas mãos: injeta a empunhadura visual secundária correspondente
            String gripAsset = "composite/" + gender + "_offhand_twohand_" + mainhand;
            int id = getOrLoadAsset(gripAsset);
            if (id != -1) {
                character.spriteIndex.a(Integer.valueOf(id));
            }
        }
    }

    private static int getOrLoadAsset(String name) {
        int id = GameAssets.a(name);
        if (id == -1) {
            // Se o asset foi registrado pelo loader agora, uma segunda chamada retorna o índice alocado
            id = GameAssets.a(name);
        }
        return id;
    }
}
