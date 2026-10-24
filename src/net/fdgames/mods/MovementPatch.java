package net.fdgames.mods;

import net.fdgames.GameEntities.MapActor$ActorState;
import net.fdgames.GameLevel.GameLevel;

public class MovementPatch {

    /**
     * Movimentação Isotrópica Perfeita:
     * No jogo original, o método P.a(f, f2) usava k(f - f2) e l(f + f2) com peso 1.0f,
     * gerando disparidade de velocidade entre os eixos.
     *
     * Com a fórmula perfeitamente simétrica:
     *   k = 2.0f * (f - f2)
     *   l = 2.0f * (f + f2)
     *
     * A magnitude vetorial no mundo (k^2 + l^2) é exatamente 8.0 para qualquer ângulo theta
     * (pois 4(1 - sin 2*theta) + 4(1 + sin 2*theta) = 8.0, o seno se anula perfeitamente).
     *
     * Isso equaliza horizontal (esquerda/direita), vertical (cima/baixo) e diagonais
     * para a mesma velocidade rápida, fluida e constante em 360 graus.
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

            // Velocidade perfeitamente simétrica e rápida em todas as direções
            GameLevel.a().k(2.0f * (f - f2));
            GameLevel.a().l(2.0f * (f + f2));
        }
    }
}
