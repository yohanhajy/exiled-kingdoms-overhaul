package net.fdgames.mods;

import com.badlogic.gdx.utils.Array;
import net.fdgames.GameEntities.Character;
import net.fdgames.GameEntities.CharacterSheet.CharacterInventory;
import net.fdgames.Rules.WeaponStats;
import net.fdgames.assets.AnimationSet;
import net.fdgames.assets.GameAssets;

public class EquipmentVisuals {

    public static void apply(Character character) {
        if (character == null || character.spriteIndex == null || character.spriteIndex.b == 0) {
            return;
        }

        // CASO A: Personagem com Inventário Dinâmico (Jogador, Boneco do Menu de Equipamentos e Companheiros: Grissenda, Hirge, Adaon)
        if (character.sheet != null && character.sheet.inventory != null) {
            applyInventoryCharacter(character);
            return;
        }

        // CASO B: NPCs, Inimigos e Chefes do Mundo (bestiary.txt) que usam camadas compostas de 2 mãos
        applyCompositeNpc(character);
    }

    private static void applyInventoryCharacter(Character character) {
        String gender = character.c(); // "male" ou "female"
        CharacterInventory inv = character.sheet.inventory;
        WeaponStats weapon = character.sheet.g();

        boolean isTwoHanded = (weapon != null && weapon.twohanded);
        boolean isRanged = (weapon != null && weapon.ranged);
        boolean isStaff = (weapon != null && weapon.staff);

        String body = character.sheet.a();
        if (body == null || body.isEmpty()) {
            // Fallback para quando o personagem ou companheiro está sem armadura equipada no peito (slot_body == 0)
            body = "clothes";
        }
        String mainhand = inv.m();

        // 1. Garantir que a arma principal (mainhand) esteja na lista de camadas sem duplicar
        int mainhandLayerIdx = -1;
        if (mainhand != null && !mainhand.isEmpty()) {
            String baseMainhandAsset = "composite/" + gender + "_mainhand_" + mainhand;
            int baseMainhandId = getOrLoadAsset(baseMainhandAsset);
            if (baseMainhandId != -1) {
                for (int i = 0; i < character.spriteIndex.b; i++) {
                    Integer layerId = (Integer) character.spriteIndex.a(i);
                    if (layerId != null && layerId.intValue() == baseMainhandId) {
                        mainhandLayerIdx = i;
                        break;
                    }
                }
                if (mainhandLayerIdx == -1) {
                    character.spriteIndex.a(Integer.valueOf(baseMainhandId));
                    mainhandLayerIdx = character.spriteIndex.b - 1;
                }
            }
        }

        // 2. Postura 1 para Armas de Duas Mãos (Espadões, Machados 2H, Malhos 2H e Cajados 2H)
        // Exclui apenas arcos (isRanged == true && isStaff == false), que usam _ranged nativo
        if (isTwoHanded && (!isRanged || isStaff)) {
            String body2hAsset = "composite/" + gender + "_" + body + "_2h";
            int body2hId = getOrLoadAsset(body2hAsset);
            if (body2hId != -1) {
                character.spriteIndex.a(0, Integer.valueOf(body2hId));
            }

            if (mainhand != null && !mainhand.isEmpty() && mainhandLayerIdx != -1) {
                String wep2hAsset = "composite/" + gender + "_mainhand_" + mainhand + "_2h";
                int wep2hId = getOrLoadAsset(wep2hAsset);
                if (wep2hId != -1) {
                    character.spriteIndex.a(mainhandLayerIdx, Integer.valueOf(wep2hId));
                }
            }
        } else if (body.equals("clothes") && (!isRanged || isStaff)) {
            // Garante que uma personagem feminina sem armadura equipada com arma de 1M use female_clothes
            // (corrige o bug nativo do Player.ac() e NPC.ac() que carregava male_clothes para mulheres sem armadura)
            String baseBodyAsset = "composite/" + gender + "_clothes";
            int baseBodyId = getOrLoadAsset(baseBodyAsset);
            if (baseBodyId != -1) {
                character.spriteIndex.a(0, Integer.valueOf(baseBodyId));
            }
        }

        // 3. Escudo ou arma secundária (slot_offhand) apenas quando não for 2H
        if (!isTwoHanded) {
            String offhand = inv.n();
            if (offhand != null && !offhand.isEmpty()) {
                String offhandAsset = "composite/" + gender + "_offhand_" + offhand;
                int offhandId = getOrLoadAsset(offhandAsset);
                if (offhandId != -1) {
                    boolean alreadyPresent = false;
                    for (int i = 0; i < character.spriteIndex.b; i++) {
                        Integer layerId = (Integer) character.spriteIndex.a(i);
                        if (layerId != null && layerId.intValue() == offhandId) {
                            alreadyPresent = true;
                            break;
                        }
                    }
                    if (!alreadyPresent) {
                        character.spriteIndex.a(Integer.valueOf(offhandId));
                    }
                }
            }
        }
    }

    private static void applyCompositeNpc(Character character) {
        int wepLayerIdx = -1;
        String wepLayerName = null;

        for (int i = 0; i < character.spriteIndex.b; i++) {
            Integer layerId = (Integer) character.spriteIndex.a(i);
            if (layerId == null) {
                continue;
            }
            AnimationSet animSet = GameAssets.a(layerId.intValue());
            if (animSet != null && animSet.name != null && isTwoHandedWeaponLayer(animSet.name)) {
                wepLayerIdx = i;
                wepLayerName = animSet.name;
                break;
            }
        }

        if (wepLayerIdx == -1 || wepLayerName == null) {
            return;
        }

        // Substitui a camada 0 (corpo composto ou corpo de NPC standalone) pela versão _2h
        Integer bodyLayerId = (Integer) character.spriteIndex.a(0);
        if (bodyLayerId != null) {
            AnimationSet bodyAnimSet = GameAssets.a(bodyLayerId.intValue());
            if (bodyAnimSet != null && bodyAnimSet.name != null && !bodyAnimSet.name.endsWith("_2h")) {
                int body2hId = getOrLoadAsset(bodyAnimSet.name + "_2h");
                if (body2hId != -1) {
                    character.spriteIndex.a(0, Integer.valueOf(body2hId));
                }
            }
        }

        // Substitui a camada da arma de 2 mãos pela versão _2h
        if (!wepLayerName.endsWith("_2h")) {
            int wep2hId = getOrLoadAsset(wepLayerName + "_2h");
            if (wep2hId != -1) {
                character.spriteIndex.a(wepLayerIdx, Integer.valueOf(wep2hId));
            }
        }
    }

    private static boolean isTwoHandedWeaponLayer(String assetName) {
        if (!assetName.startsWith("composite/")) {
            return false;
        }
        return assetName.endsWith("_mainhand_zweihander")
            || assetName.endsWith("_mainhand_greatsword")
            || assetName.endsWith("_mainhand_battleaxe")
            || assetName.endsWith("_mainhand_maul")
            || assetName.endsWith("_mainhand_staff")
            || assetName.endsWith("_mainhand_greatstaff");
    }

    private static int getOrLoadAsset(String name) {
        int id = GameAssets.a(name);
        if (id == -1) {
            id = GameAssets.a(name);
        }
        return id;
    }
}
