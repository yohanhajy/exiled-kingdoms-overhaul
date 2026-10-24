package net.fdgames.mods;

import net.fdgames.GameEntities.MapActor$ActorState;
import net.fdgames.GameLevel.GameLevel;

public class MovementPatch {

    /**
     * Multiplicador de velocidade calibrado (1.5f):
     * Reduzido uniformemente em 25% (de 2.0f para 1.5f) para manter o ritmo de caminhada
     * ágil e natural, garantindo que a habilidade 'Sprint' (+50% do Ladino / poções de velocidade)
     * mantenha um impacto nítido de aceleração.
     *
     * Fórmula perfeitamente isotrópica e simétrica em 360°:
     *   k = 1.5f * (f - f2)
     *   l = 1.5f * (f + f2)
     */
    public static void updateMovement(float f, float f2) {
        if (!GameLevel.m() && GameLevel.a().ao() != MapActor$ActorState.f && GameLevel.a().ao() != MapActor$ActorState.h) {
            if (f == 0.0f && f2 == 0.0f) {
                GameLevel.a().k(0.0f);
                GameLevel.a().l(0.0f);
                return;
            }

            // Normalização vetorial euclidiana
            float len = (float) Math.sqrt(f * f + f2 * f2);
            if (len > 1.0f) {
                f /= len;
                f2 /= len;
            }

            // Velocidade perfeitamente uniforme e calibrada (-25%)
            GameLevel.a().k(1.5f * (f - f2));
            GameLevel.a().l(1.5f * (f + f2));
        }
    }
}
