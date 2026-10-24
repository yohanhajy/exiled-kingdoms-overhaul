# Status do Projeto: Exiled Kingdoms Overhaul

> **Data de Atualização:** 24 de Outubro de 2026  
> **Plataforma:** Exiled Kingdoms (Steam Nativo Linux / Engine LibGDX / OpenJDK 1.7)  
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

### E. Documentação Técnica Existente
- [`GUIA_MESTRE_MODDING_EXILED_KINGDOMS.md`](file:///home/yhn/Projetos/exiled-kingdoms-mod/GUIA_MESTRE_MODDING_EXILED_KINGDOMS.md): Relatório com engenharia reversa completa do motor LibGDX, guias de injeção de código, estruturas de mapa TMX, eventos, UI e teorias de câmera e mapa contínuo.

---

## 2. Próximos Passos Planejados (Para o Overhaul)
- [ ] Inicialização de repositório Git local e remoto no GitHub (controle de versões).
- [ ] Customização e modernização de interfaces de usuário (HUD/UI, barras de vida, inventário expandido).
- [ ] Engenharia de mapa contínuo sem telas de transição (carregamento dinâmico de chunks TMX).
- [ ] Novas classes, árvores de habilidades e rebalanceamento de combate.
