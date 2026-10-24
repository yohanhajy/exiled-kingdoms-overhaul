# Exiled Kingdoms Overhaul (Linux / Steam)

> Projeto de modernização, melhorias de qualidade de vida (QoL), correções de conteúdo cortado e expansão para a versão nativa Steam (Linux) do clássico RPG **Exiled Kingdoms**.

---

## ⚔️ Sobre o Projeto

O **Exiled Kingdoms Overhaul** é um conjunto de modificações profundas e modulares para o motor LibGDX (Java) de Exiled Kingdoms. O objetivo é aprimorar visualmente, corrigir pontas soltas do jogo base e introduzir mecânicas modernas preservando a identidade clássica do RPG.

### Principais Funcionalidades Implementadas

* **Armas e Escudos Visíveis em Tempo Real**:
  * Resgate e ativação do sistema cortado de sprites compostos da engine original.
  * Todas as armas (espadas, machados, martelos, adagas, cajados, arcos) e escudos aparecem empunhados pelo personagem e companheiros ao equipar.
* **Física de Movimentação Isométrica Uniforme 360°**:
  * Correção do bug nativo de proporção 2:1 da engine que deixava a movimentação vertical (cima/baixo) 50% mais lenta que a horizontal.
  * Normalização vetorial Euclidiana para velocidade homogênea em todas as direções (teclado, gamepad e analógicos).
* **Fim das Armaduras Genéricas (40 Novos Spritesheets)**:
  * 40 novas folhas de texturas compostas em alta definição ($1260 \times 1540$ RGBA), corrigindo armaduras, capas, elmos e escudos que usavam gráficos cinzas genéricos no jogo original (Tolassiana Vermelha, Gelo Ancestral Azul, Malha da Floresta, Placas da Legião Douradas, Obsidiana Negra, Placas Thuramianas/Myrosianas Nobres, Couro de Troll Verde, Capuzes Mágicos Coloridos).
* **Auditoria Completa de Equipamentos (`items.txt`)**:
  * Revisão integral dos 432 itens equipáveis do jogo.
  * Correção de bugs visuais nativos (elmos que deixavam o personagem careca ou com malha trocada).
* **Arquitetura de Injeção Não-Destrutiva**:
  * O jogo original da Steam não é corrompido nem sobrescrito. As modificações são injetadas em tempo de inicialização via manipulação limpa de classpath (`mods/`), permitindo ativar ou desativar com um comando.

---

## 🗺️ Roadmap de Desenvolvimento

- [x] Arquitetura de compilação compatível com runtime Java 7 nativo.
- [x] Injeção dinâmica de armas, escudos e armaduras visíveis.
- [x] 40 spritesheets personalizados para equipamentos únicos.
- [x] Auditoria de banco de dados de itens e balanceamento básico.
- [ ] Modernização da interface de usuário (HUD, barras de HP/Mana/XP, minimapa expandido).
- [ ] Mundo Aberto Contínuo (*Seamless Chunk Streaming 3x3* sem telas de carregamento entre setores externos).
- [ ] Novas classes, árvores de habilidades e rebalanceamento de monstros e encontros.

---

## 🛠️ Como Compilar e Instalar

### Pré-requisitos
* Sistema Linux (testado e otimizado para Steam Nativo).
* JRE/JDK instalado (OpenJDK 8 ou superior para rodar o compilador).
* Jogo original **Exiled Kingdoms** instalado via Steam em:
  `~/.local/share/Steam/steamapps/common/Exiled Kingdoms`

### Instalação em 1 Passo
Clone o repositório e execute o script de build:
```bash
./build_mod.sh
```
O script compilará os patches em bytecode, ajustará para compatibilidade Java 7, sincronizará texturas e configurará o launcher da Steam automaticamente.

### Desinstalação
Para reverter o jogo ao estado 100% original da Steam a qualquer momento:
```bash
./uninstall_mod.sh
```

---

## ⚖️ Licença e Avisos
* As ferramentas de injeção, scripts de build e códigos de modding originais são distribuídos sob licença aberta para a comunidade.
* *Exiled Kingdoms* é uma marca e criação de 4 Dimension Games. Este mod não redistribui os binários proprietários do jogo original, exigindo uma cópia legítima adquirida na Steam.
