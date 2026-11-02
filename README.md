# Exiled Kingdoms Overhaul (Linux & Windows)

> Projeto experimental de modernização, melhorias de qualidade de vida (QoL), correções de conteúdo cortado e expansão para a versão Steam de **Exiled Kingdoms**.

---

> [!IMPORTANT]
> ### 🤖 Projeto Amador Desenvolvido com Inteligência Artificial
> Este projeto é um **trabalho amador e experimental de modding**, desenvolvido com o auxílio direto de Inteligência Artificial:
> * **Google Antigravity**: Ambiente de execução e harness agêntico de desenvolvimento de software.
> * **Google Gemini 3.8 Flash**: Geração e refatoração de código, automação de scripts de patching e geração procedural de spritesheets.
> * **Google Gemini Argon (Low)**: Raciocínio arquitetural para os desafios e tarefas de engenharia reversa de maior complexidade.
>
> ⚠️ **Aviso sobre Releases:** Este projeto encontra-se em fase ativa de experimentação interna. **Não há releases ou instaladores públicos (seja para Windows ou Linux) disponíveis no momento.** Não utilize nem procure pacotes executáveis prontos antes do momento oportuno.

---

## ⚔️ Sobre o Projeto

O **Exiled Kingdoms Overhaul** é um conjunto de modificações profundas e modulares para o motor LibGDX (Java) de Exiled Kingdoms. O objetivo é aprimorar visualmente, corrigir pontas soltas do jogo base e introduzir mecânicas modernas preservando a identidade clássica do RPG.

### Principais Funcionalidades Implementadas

* **Empunhadura Realista para Armas de Duas Mãos (2H Stance - V8 Universal)**:
  * Sistema visual onde armas de duas mãos (machados de batalha, montantes, martelos pesados e cajados mágicos) são empunhadas com ambas as mãos apoiadas no ombro.
  * Algoritmo de rastreamento com compensação vetorial de cabeça (*head-delta offset*) para manter a empunhadura natural em todas as 8 direções e nos 5 frames do ciclo de caminhada.
  * 65 spritesheets compostos gerados para cobertura universal: personagem principal (masculino e feminino), companheiros, mercenários, NPCs e chefes.
* **Armas e Escudos Visíveis em Tempo Real**:
  * Resgate e ativação do sistema cortado de sprites compostos da engine original.
  * Todas as armas (espadas, machados, martelos, adagas, cajados, arcos) e escudos aparecem empunhados pelo personagem e companheiros ao equipar.
* **Física de Movimentação Isométrica Uniforme 360°**:
  * Correção do bug nativo de proporção 2:1 da engine que deixava a movimentação vertical (cima/baixo) 50% mais lenta que a horizontal.
  * Normalização vetorial Euclidiana para velocidade homogênea em todas as direções para o jogador, companheiros e monstros perseguidores.
* **Fim das Armaduras Genéricas (40 Novos Spritesheets)**:
  * 40 folhas de texturas compostas em alta definição ($1260 \times 1540$ RGBA), corrigindo armaduras, capas, elmos e escudos que usavam gráficos cinzas genéricos no jogo original (Tolassiana Vermelha, Gelo Ancestral Azul, Malha da Floresta, Placas da Legião Douradas, Obsidiana Negra, Placas Thuramianas/Myrosianas Nobres, Couro de Troll Verde, Capuzes Mágicos Coloridos).
* **Auditoria Completa de Equipamentos (`items.txt`)**:
  * Revisão integral dos 432 itens equipáveis do jogo.
  * Correção de bugs visuais nativos (elmos que deixavam o personagem careca ou com malha trocada).
* **Arquitetura de Injeção Não-Destrutiva**:
  * O arquivo original do jogo (`exiledkingdoms.jar`) **NUNCA** é modificado nem sobrescrito. As modificações são injetadas dinamicamente via classpath prioritário (`mods/`), permitindo ativar ou desativar com total segurança e sem corromper arquivos da Steam.

---

## 🧪 Ambiente de Desenvolvimento e Testes

Por ser um projeto em desenvolvimento ativo, as modificações são testadas diretamente pelo código-fonte:

### Estrutura do Repositório
* `src/`: Código-fonte Java dos patches de motor e QoL (`EquipmentVisuals.java`, etc.).
* `mods/`: Bytecodes compilados para Java 7 (major version 51) e assets customizados prontos para injeção.
* `tools/`: Utilitários de análise de bytecode e scripts de geração de assets (ex: `build_2h_postura1.py`).
* `docs/`: Documentações técnicas, laudos de engenharia reversa e arquitetura do motor.

### Compilação e Sincronização Local
```bash
# Compilar patches Java (compatíveis com Java 7) e sincronizar assets com a Steam local
./build_mod.sh

# Reverter e desinstalar o mod da pasta local da Steam a qualquer momento
./uninstall_mod.sh
```

---

## 🗺️ Roadmap de Desenvolvimento

- [x] Arquitetura de injeção dinâmica compatível com runtime Java 7 nativo.
- [x] Injeção dinâmica de armas, escudos e armaduras visíveis.
- [x] 40 spritesheets personalizados para equipamentos únicos.
- [x] Auditoria de banco de dados de itens e balanceamento básico.
- [x] Movimentação isométrica uniforme em 360° para jogador e NPCs.
- [x] Empunhadura visual artesanal para armas de duas mãos (2H Stance V8 Universal).
- [ ] Mundo Aberto Contínuo (*Seamless Chunk Streaming 3x3* sem telas pretas de transição).
- [ ] Modernização da interface de usuário (HUD, barras de status, minimapa).
- [ ] Empacotamento de instaladores universais e releases públicas oficiais (planejado para quando o mod atingir maturação completa).

---

## ⚖️ Licença e Avisos
* As ferramentas de injeção, scripts de build e códigos de modding originais são distribuídos sob licença aberta para a comunidade.
* *Exiled Kingdoms* é uma marca e criação de 4 Dimension Games. Este mod não redistribui os binários proprietários do jogo original, exigindo uma cópia legítima adquirida na Steam.
