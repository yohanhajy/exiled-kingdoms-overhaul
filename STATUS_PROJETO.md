# Status do Projeto: Exiled Kingdoms Overhaul

> **Data de Atualização:** 24 de Outubro de 2026  
> **Plataforma:** Exiled Kingdoms (Steam Nativo Linux & Windows / Engine LibGDX / OpenJDK 1.7)  
> **Repositório GitHub:** `https://github.com/yohanhajy/exiled-kingdoms-overhaul`  
> **Diretório do Modding:** `/home/yhn/Projetos/exiled-kingdoms-mod`  
> **Diretório do Jogo:** `/home/yhn/.local/share/Steam/steamapps/common/Exiled Kingdoms`  

---

## 1. O Que Já Foi Implementado e Corrigido

### A. Infraestrutura e Toolchain de Modding (100% Funcional e Não-Destrutivo)
- **Descompilador & Manipulador Bytecode:** Configurados `cfr.jar` e `javassist.jar` no diretório `tools/` do projeto.
- **Carregamento Prioritário Steam:** O launcher nativo (`config.json`) foi configurado para priorizar a pasta `mods/` sobre o executável base `exiledkingdoms.jar`.
- **Compatibilidade Java 7:** Bytecode gerado e corrigido para versão 51 (Java 7), garantindo estabilidade nativa no runtime embarcado pelo jogo.
- **Automação de Build:** Criados scripts utilitários:
  - `build_mod.sh`: Compila, injeta bytecodes, sincroniza tabelas (`items.txt`) e texturas.
  - `uninstall_mod.sh`: Reverte o jogo instantaneamente para o estado original da Steam.

---

### B. Correção de "Preguiça de Dev" e 40 Novos Spritesheets
No jogo original, diversas armaduras e itens possuíam ícones únicos coloridos no inventário, mas quando equipados exibiam uma textura genérica cinza ou marrom. 

Foram gerados **40 novos spritesheets compostos** em alta resolução ($1260 \times 1540$ RGBA), cobrindo animações completas para **personagens masculinos e femininos**:

1. **Cota de Malha Carmesim de Tolassia:** `mail_red.png` e `head_chain_red.png`
2. **Cota de Malha Florestal e Velites (Verde):** `mail_forest.png` e `head_chain_forest.png`
3. **Cota de Malha Abençoada e Gelo Ancestral (Azul Celeste):** `mail_blue.png` e `head_chain_blue.png`
4. **Armadura de Placas da Legião Imperial (Dourado):** `plate_gold.png` e `head_plate_gold.png`
5. **Armadura de Placas Sagradas / Abençoadas (Azul Cobalto):** `plate_blue.png` e `head_plate_blue.png`
6. **Armadura de Placas de Obsidiana Cinzenta (Preto Vulcânico):** `plate_black.png` e `head_plate_black.png`
7. **Armadura de Placas Myrosiana / Thuramiana (Rosa Suave / Vinho):** `plate_epic.png` e `head_plate_epic.png` *(calibrado com precisão para evitar rosa-choque)*
8. **Couro de Troll e Caçador (Verde Musgo):** `leather_green.png` e `head_leather_green.png`
9. **Capuzes de Mago Coloridos:** `head_hood_green.png` (Verde/Aprendiz) e `head_hood_blue.png` (Azul/Conjurador)
10. **Escudos e Broquéis Vermelhos:** `offhand_buckler_red.png` e `offhand_shield2_red.png`

---

### C. Auditoria Geral e Correção da Base de Dados (`items.txt`)
Todos os **432 itens equipáveis** do jogo foram auditados um a um:
- **44 Armaduras de Tronco (`armor_chest`):** 100% mapeadas para texturas correspondentes.
- **33 Elmos e Capuzes (`armor_head`):** 100% verificados.
- **56 Escudos e Focos (`SHIELD`):** 37 escudos físicos com gráficos corrigidos; 19 focos mágicos (orbes, totens, crânios) mantidos como itens de mão sem carcaça de madeira/metal.
- **196 Armas (`WEAPON`):** 100% funcionais nas suas categorias de sprite.
- **Bugs Nativos do Jogo Corrigidos:**
  - `Leather Cap` (ID 104): Sprite estava vazio no original (personagem ficava careca). Corrigido para `leather`.
  - `Knight Helm` (ID 119): Estava incorretamente associado a um capuz de malha aberto (`chain`). Corrigido para elmo com visor de cavaleiro (`plate`).
  - `Cowl of Fellowship` (ID 210) & `Hood of the Hermit` (ID 339): Sprites vazios corrigidos para `hood`.

---

### D. Save de Testes e Vitrine em New Garand
- Saves configurados no **Slot 0** e **Slot 1** (`data/saves/0/game2.sav` e `data/saves/1/game.sav`).
- Personagem de teste: **Guerreiro Nível 24/20**, com **~965.000 de ouro** na capital de New Garand.
- **Mochila e Baús:** Repletos de cópias dos novos conjuntos de armaduras, elmos e escudos para conferência imediata das trocas de visual.

---

### E. Correção Crítica de Física: Movimentação Isométrica Uniforme 360° (Jogador e NPCs/Inimigos)
No jogo original, o criador cometeu um erro matemático de projeção isométrica 2:1 (`ScreenX = x + y`, `ScreenY = (y - x) / 2`). Ao repassar os comandos direcionais do teclado/controle e os passos de pathfinding da IA com peso 1:1, a velocidade vertical ficava com apenas **50% da velocidade horizontal** tanto para o jogador quanto para todos os inimigos e companheiros.
- **Implementado [`MovementPatch.java`](file:///home/yhn/Projetos/exiled-kingdoms-mod/src/net/fdgames/mods/MovementPatch.java)**:
  * Injetada compensação de 2.0x no eixo vertical (`k(C * (f - 2.0f * f2))`, `l(C * (f + 2.0f * f2))`) com constante calibrada $C = 0.80f$.
  * Normalização vetorial Euclidiana ($\sqrt{x^2 + y^2}$) para velocidade homogênea em 360° ($1.60\text{ px/tick}$ em todos os eixos).
  * **Estendido para Todos os NPCs, Inimigos e Companheiros**: Interceptado `Character.H()` (o motor de pathfinding do jogo), garantindo perseguição e escolta perfeitas.
  * Bytecodes de `P.class` e `Character.class` interceptados via Javassist e sincronizados no jogo.

---

### F. Investigação Anatômica & Auditoria Forense das Armas de Duas Mãos
No jogo original, equipar uma arma de duas mãos desativa o slot de mão secundária, mas no modelo visual a arma continua sendo segurada por apenas uma mão (a direita), mantendo o braço esquerdo inerte na cintura.
- **Censo dos 80 Equipamentos 2H:** Catalogados todos os 80 itens de duas mãos em 8 arquétipos (`greatsword`, `zweihander`, `battleaxe`, `maul`, `greatstaff`, `staff`, `longbow`, `shortbow`).
- **Auditoria do Guardião de Bugs:** Diagnosticada a falha da rota ingênua ("Resting on Shoulder") durante caminhada e ataque, a assimetria anatômica entre arcos (mão esquerda) e espadas (mão direita), e a especificação da técnica de *Joint Mask Sampling*.
- **Relatório Forense & Laudo Crítico:** Documentado formalmente em [`docs/ANALISE_FORENSE_EQUIPAMENTOS_DUAS_MAOS.md`](file:///home/yhn/Projetos/exiled-kingdoms-mod/docs/ANALISE_FORENSE_EQUIPAMENTOS_DUAS_MAOS.md) e arquivado para a fase de pixel art artesanal.

---

### G. Instaladores Universais em 1 Clique (Linux & Windows)
Para garantir uma experiência amigável, segura e profissional tanto para usuários de Windows quanto de qualquer distribuição Linux:
- **Windows (Instalador Nativo e Confiável):** Criado script Inno Setup [`installer/windows/setup.iss`](file:///home/yhn/Projetos/exiled-kingdoms-mod/installer/windows/setup.iss) compilado em `release/ExiledKingdomsOverhaul-Setup-v1.0.0.exe`. Ele substitui scripts `.bat` suspeitos por um instalador visual profissional padrão do Windows, com detecção automática do Steam no Registro (`HKEY_CURRENT_USER\Software\Valve\Steam`), backup seguro de `config.json` e registro no Desinstalador de Aplicativos do Windows (`unins000.exe`).
- **Linux (Compatibilidade POSIX Estrita):** Criado [`installer/linux/install.sh`](file:///home/yhn/Projetos/exiled-kingdoms-mod/installer/linux/install.sh) em `/bin/sh` estritamente POSIX (validado com `sh --posix`), sem qualquer bashism, compatível com Ubuntu, Debian, Fedora, Arch, openSUSE, Void, Alpine e SteamOS (Steam Deck). Detecta automaticamente diretórios padrão, Flatpak, Snap e múltiplos discos via `libraryfolders.vdf`.
- **Pipeline de Empacotamento Automatizado:** Script [`package_release.sh`](file:///home/yhn/Projetos/exiled-kingdoms-mod/package_release.sh) gera os pacotes `Setup.exe`, `Linux.tar.gz`, `Linux.zip`, `Universal.zip` e suas somas de verificação SHA-256.
- **GitHub Actions CI/CD:** Workflow [`.github/workflows/release.yml`](file:///home/yhn/Projetos/exiled-kingdoms-mod/.github/workflows/release.yml) automatiza a publicação de releases anexando os binários a cada tag `v*`.

---

### H. Documentação Técnica & Especificações Arquiteturais
- [`GUIA_MESTRE_MODDING_EXILED_KINGDOMS.md`](file:///home/yhn/Projetos/exiled-kingdoms-mod/GUIA_MESTRE_MODDING_EXILED_KINGDOMS.md): Relatório com engenharia reversa completa do motor LibGDX, guias de injeção de código, estruturas de mapa TMX, eventos, UI e teorias de câmera.
- [`docs/ANALISE_FORENSE_EQUIPAMENTOS_DUAS_MAOS.md`](file:///home/yhn/Projetos/exiled-kingdoms-mod/docs/ANALISE_FORENSE_EQUIPAMENTOS_DUAS_MAOS.md): Diagnóstico anatômico, censo dos 80 itens e blueprint de oclusão via Joint Mask Sampling.
- [`docs/ANALISE_ARQUITETURA_MUNDO_ABERTO_CONTINUO.md`](file:///home/yhn/Projetos/exiled-kingdoms-mod/docs/ANALISE_ARQUITETURA_MUNDO_ABERTO_CONTINUO.md): Auditoria completa do Guardião de Bugs com os 6 grandes poréns do motor, diagrama dos 12 passos destrutivos de transição e o plano em 5 fases para a grade contínua $3 \times 3$.
- [`docs/PLANO_UNIVERSAL_RELEASES_LINUX_WINDOWS.md`](file:///home/yhn/Projetos/exiled-kingdoms-mod/docs/PLANO_UNIVERSAL_RELEASES_LINUX_WINDOWS.md): Especificação dos instaladores universais em 1 clique e arquitetura multiplataforma.

---

### I. Repositório Git e Sincronização Remota no GitHub
- Repositório remoto configurado e sincronizado: [`https://github.com/yohanhajy/exiled-kingdoms-overhaul`](https://github.com/yohanhajy/exiled-kingdoms-overhaul).
- Chave SSH ED25519 registrada e commits devidamente autenticados no branch `main`.

---

## 2. Próximos Passos Planejados (Para o Overhaul)
- [x] Inicialização de repositório Git local e remoto no GitHub (`exiled-kingdoms-overhaul`).
- [x] Correção de velocidade de movimentação 360° em todos os eixos (jogador, NPCs, companheiros e monstros).
- [x] Auditoria anatômica dos 80 equipamentos de duas mãos e blueprint de oclusão.
- [x] Auditoria forense e blindagem conceitual para transição contínua de mapas sem telas pretas.
- [x] **Instaladores Universais em 1 Clique:** Criação de `install.sh` (POSIX Linux) e `Setup.exe` (Inno Setup Windows) com detecção automática da Steam e pipeline CI/CD.
- [ ] **Mundo Aberto Contínuo:** Implementação do `WorldTopology.java` e `VirtualCollisionGrid`.
- [ ] **Empunhadura Visual 2H:** Arte pixel art dedicada para postura de duas mãos com Joint Mask Sampling.
- [ ] Customização e modernização de interfaces de usuário (HUD/UI, barras de vida, inventário expandido).
- [ ] Novas classes, árvores de habilidades e rebalanceamento de combate.
