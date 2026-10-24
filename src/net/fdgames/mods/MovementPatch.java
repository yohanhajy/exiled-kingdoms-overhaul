package net.fdgames.mods;

import net.fdgames.GameEntities.MapActor$ActorState;
import net.fdgames.GameLevel.GameLevel;

public class MovementPatch {

    /**
     * Corrige a discrepância de velocidade entre movimento horizontal e vertical.
     * Na engine LibGDX de Exiled Kingdoms, a projeção isométrica converte coordenadas para a tela como:
     *   ScreenX = x + y
     *   ScreenY = (y - x) / 2
     *
     * No jogo original, o método P.a(f, f2) aplicava o mesmo fator 1:1 para ambos os eixos,
     * fazendo com que a movimentação vertical (cima/baixo) tivesse exatamente metade (50%)
     * da velocidade da movimentação horizontal (esquerda/direita).
     *
     * Ao aplicar a compensação de 2.0x no componente vertical (f2) e normalização euclidiana,
     * a velocidade se torna rigorosamente uniforme em 360 graus.
     */
    public static void updateMovement(float f, float f2) {
        if (!GameLevel.m() && GameLevel.a().ao() != MapActor$ActorState.f && GameLevel.a().ao() != MapActor$ActorState.h) {
            if (f == 0.0f && f2 == 0.0f) {
                GameLevel.a().k(0.0f);
                GameLevel.a().l(0.0f);
                return;
            }

            // Normalização vetorial euclidiana para velocidade constante em qualquer ângulo
            float len = (float) Math.sqrt(f * f + f2 * f2);
            if (len > 1.0f) {
                f /= len;
                f2 /= len;
            }

            // Compensação isotrópica para projeção isométrica 2:1
            GameLevel.a().k(f - 2.0f * f2);
            GameLevel.a().l(f + 2.0f * f2);
        }
    }
}
