package net.fdgames.mods;

import net.fdgames.GameEntities.MapActor$ActorState;
import net.fdgames.GameLevel.GameLevel;

public class MovementPatch {

    /**
     * Compensação Isométrica 2:1 com Velocidade Proporcionalmente Idêntica:
     *
     * Na engine LibGDX de Exiled Kingdoms:
     *   ScreenX = speedX + speedY = 2 * C * f
     *   ScreenY = (speedY - speedX) / 2 = 2 * C * f2
     *
     * Para que a velocidade na tela seja RIGOROSAMENTE IDÊNTICA em todas as direções,
     * o componente vertical f2 deve receber o dobro (2.0f) do peso do horizontal f:
     *   k = C * (f - 2.0f * f2)
     *   l = C * (f + 2.0f * f2)
     *
     * Com C = 0.80f:
     *   - Esquerda / Direita: exatos 1.60f na tela
     *   - Cima / Baixo: exatos 1.60f na tela
     *   - Diagonais: exatos 1.60f na tela
     *
     * Velocidade 100% uniforme e proporcional em 360°, sem correr em disparada
     * e sem lentidão vertical.
     */
    private static final float C = 0.80f;

    public static void updateMovement(float f, float f2) {
        if (!GameLevel.m() && GameLevel.a().ao() != MapActor$ActorState.f && GameLevel.a().ao() != MapActor$ActorState.h) {
            if (f == 0.0f && f2 == 0.0f) {
                GameLevel.a().k(0.0f);
                GameLevel.a().l(0.0f);
                return;
            }

            // Normalização vetorial euclidiana para manter velocidade constante em diagonais
            float len = (float) Math.sqrt(f * f + f2 * f2);
            if (len > 1.0f) {
                f /= len;
                f2 /= len;
            }

            // Proporção matemática perfeita: ScreenX = 1.60f, ScreenY = 1.60f
            GameLevel.a().k(C * (f - 2.0f * f2));
            GameLevel.a().l(C * (f + 2.0f * f2));
        }
    }
}
