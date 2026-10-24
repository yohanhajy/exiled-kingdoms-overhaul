package net.fdgames.mods;

import net.fdgames.GameEntities.Character;
import net.fdgames.GameEntities.Final.Player;
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
     */
    private static final float C = 0.80f;

    public static void updateMovement(float f, float f2) {
        if (GameLevel.m()) {
            return;
        }

        Player player = GameLevel.a();
        if (player == null) {
            return;
        }

        if (player.ao() == MapActor$ActorState.f || player.ao() == MapActor$ActorState.h) {
            return;
        }

        if (f == 0.0f && f2 == 0.0f) {
            player.k(0.0f);
            player.l(0.0f);
            return;
        }

        // Normalização vetorial euclidiana para manter velocidade constante em diagonais
        float len = (float) Math.sqrt(f * f + f2 * f2);
        if (len > 1.0f) {
            f /= len;
            f2 /= len;
        }

        // Proporção matemática perfeita: ScreenX = 1.60f, ScreenY = 1.60f
        player.k(C * (f - 2.0f * f2));
        player.l(C * (f + 2.0f * f2));
    }

    /**
     * Aplica a compensação isométrica uniforme para todos os NPCs, Companheiros e Inimigos.
     * Intercepta Character.H() (o motor de movimentação e pathfinding A* do jogo).
     */
    public static void updateCharacterMovement(Character c) {
        if (c == null) {
            return;
        }

        // Blindagem contra velocidade zumbi / deslizamento quando o destino for cancelado ou alcançado
        if (c.al() == null || c.al().x == -1 || c.al().y == -1 || c.n()) {
            c.k(0.0f);
            c.l(0.0f);
            return;
        }

        float dx = (float) (c.al().x - c.x);
        float dy = (float) (c.al().y - c.y);

        if (dx == 0.0f && dy == 0.0f) {
            c.k(0.0f);
            c.l(0.0f);
            return;
        }

        // Vetor de deslocamento na tela isométrica:
        // ScreenX = dx + dy
        // ScreenY = (dy - dx) / 2.0f
        float screenX = dx + dy;
        float screenY = (dy - dx) / 2.0f;

        float len = (float) Math.sqrt(screenX * screenX + screenY * screenY);
        if (len <= 0.0001f) {
            c.k(0.0f);
            c.l(0.0f);
            return;
        }

        float f = screenX / len;
        float f2 = screenY / len;

        // Aplica a mesma calibração isométrica do jogador (C = 0.80f),
        // escalada pelo speedModifier original do monstro/NPC/companheiro
        float mod = c.speedModifier;
        c.k(C * (f - 2.0f * f2) * mod);
        c.l(C * (f + 2.0f * f2) * mod);
    }
}
