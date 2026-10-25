# Exiled Kingdoms Overhaul (Linux & Windows)

> Projeto de modernização, melhorias de qualidade de vida (QoL), correções de conteúdo cortado e expansão para a versão Steam de **Exiled Kingdoms**.
> Compatibilidade universal com **Linux** (Ubuntu, Debian, Fedora, Arch, openSUSE, SteamOS / Steam Deck) e **Windows**.

---

## ⚔️ Sobre o Projeto

O **Exiled Kingdoms Overhaul** é um conjunto de modificações profundas e modulares para o motor LibGDX (Java) de Exiled Kingdoms. O objetivo é aprimorar visualmente, corrigir pontas soltas do jogo base e introduzir mecânicas modernas preservando a identidade clássica do RPG.

### Principais Funcionalidades Implementadas

* **Armas e Escudos Visíveis em Tempo Real**:
  * Resgate e ativação do sistema cortado de sprites compostos da engine original.
  * Todas as armas (espadas, machados, martelos, adagas, cajados, arcos) e escudos aparecem empunhados pelo personagem e companheiros ao equipar.
* **Física de Movimentação Isométrica Uniforme 360°**:
  * Correção do bug nativo de proporção 2:1 da engine que deixava a movimentação vertical (cima/baixo) 50% mais lenta que a horizontal.
  * Normalização vetorial Euclidiana para velocidade homogênea em todas as direções para o jogador, companheiros e monstros perseguidores.
* **Fim das Armaduras Genéricas (40 Novos Spritesheets)**:
  * 40 novas folhas de texturas compostas em alta definição ($1260 \times 1540$ RGBA), corrigindo armaduras, capas, elmos e escudos que usavam gráficos cinzas genéricos no jogo original (Tolassiana Vermelha, Gelo Ancestral Azul, Malha da Floresta, Placas da Legião Douradas, Obsidiana Negra, Placas Thuramianas/Myrosianas Nobres, Couro de Troll Verde, Capuzes Mágicos Coloridos).
* **Auditoria Completa de Equipamentos (`items.txt`)**:
  * Revisão integral dos 432 itens equipáveis do jogo.
  * Correção de bugs visuais nativos (elmos que deixavam o personagem careca ou com malha trocada).
* **Arquitetura de Injeção Não-Destrutiva**:
  * O arquivo original do jogo (`exiledkingdoms.jar`) **NUNCA** é modificado nem sobrescrito. As modificações são injetadas dinamicamente via classpath prioritário (`mods/`), permitindo ativar ou desativar com total segurança e sem corromper arquivos da Steam.

---

## 📦 Como Instalar (Para Jogadores)

Não é necessário compilar nem instalar ferramentas de desenvolvimento. Basta baixar o pacote correspondente na aba [Releases](https://github.com/yohanhajy/exiled-kingdoms-overhaul/releases):

### Windows
1. Baixe o executável oficial **`ExiledKingdomsOverhaul-Setup-v1.0.0.exe`**.
2. Dê dois cliques para abrir o assistente de instalação visual.
3. A pasta do Exiled Kingdoms na Steam será detectada automaticamente (via Registro do Windows).
4. Clique em **Avançar** e **Instalar**.
5. Abra o jogo normalmente pela Steam!
6. *Para desinstalar:* Utilize o desinstalador em "Configurações > Aplicativos" do Windows ou execute `unins000.exe` na pasta do jogo.

### Linux & Steam Deck
1. Baixe **`ExiledKingdomsOverhaul-v1.0.0-Linux.tar.gz`** (ou `.zip`).
2. Extraia o arquivo e abra um terminal na pasta extraída.
3. Execute o instalador universal:
   ```bash
   ./install.sh
   ```
4. O script detectará automaticamente a instalação do Steam (incluindo Ubuntu/Debian, Fedora, Arch, openSUSE, Flatpak, Snap e Steam Deck) e aplicará o mod.
5. *Para desinstalar:* Execute `./uninstall.sh` a qualquer momento para restaurar o jogo original.

---

## 🛠️ Para Desenvolvedores e Modders

### Estrutura do Repositório
* `src/`: Código-fonte Java dos patches de motor e QoL.
* `mods/`: Bytecodes Java 7 compilados e assets prontos para injeção.
* `installer/`: Scripts do instalador universal Linux e Inno Setup do Windows.
* `tools/`: Utilitários de bytecode (`javassist.jar`, `cfr.jar`).
* `docs/`: Laudos periciais, relatórios forenses e arquiteturas de sistema.

### Compilação e Empacotamento
```bash
# Compilar código Java e sincronizar com o jogo local
./build_mod.sh

# Gerar pacotes de release universais (Windows Setup.exe + Linux tarball/zip)
./package_release.sh
```

---

## 🗺️ Roadmap de Desenvolvimento

- [x] Arquitetura de injeção dinâmica compatível com runtime Java 7 nativo.
- [x] Injeção dinâmica de armas, escudos e armaduras visíveis.
- [x] 40 spritesheets personalizados para equipamentos únicos.
- [x] Auditoria de banco de dados de itens e balanceamento básico.
- [x] Movimentação isométrica uniforme em 360° para jogador e NPCs.
- [x] Instaladores universais em 1 clique (Setup.exe para Windows e POSIX install.sh para Linux).
- [ ] Empunhadura visual artesanal para armas de duas mãos (2H Stance).
- [ ] Mundo Aberto Contínuo (*Seamless Chunk Streaming 3x3* sem telas pretas de transição).
- [ ] Modernização da interface de usuário (HUD, barras de status, minimapa).

---

## ⚖️ Licença e Avisos
* As ferramentas de injeção, scripts de build e códigos de modding originais são distribuídos sob licença aberta para a comunidade.
* *Exiled Kingdoms* é uma marca e criação de 4 Dimension Games. Este mod não redistribui os binários proprietários do jogo original, exigindo uma cópia legítima adquirida na Steam.
