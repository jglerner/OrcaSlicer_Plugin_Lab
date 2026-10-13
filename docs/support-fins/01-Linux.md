# Capítulo 1: Support Fins no Linux

> Leia antes a [visão geral](00-Visao_Geral.md). Status: **aguardando o primeiro teste**.

## Ambiente de teste (preencher)

| Item | Valor |
|---|---|
| Distribuição / versão | Debian GNU/Linux 13 (trixie), kernel 6.12.111+deb13-amd64, x86_64 |
| Desktop (X11/Wayland) | |
| OrcaSlicer estável instalado | **2.3.0**, AppImage em `~/Applications/orca/` (sem atalho no menu; a 2.4.2 não está neste Linux) |
| OrcaSlicer nightly testado | **2.5.0** (nightly de 13/10/2026), aberta com `scripts/orca-nightly.sh` |
| Plugin: versão / sha256 | 0.1.0 / `65df17faabfbd870918b3f0fdc95e460229241afb996e2fb8ab830871706963f` (build de `plugins-latest` após o commit `a517023` do support-fins, 13/10/2026) |
| Perfil de impressora | Creality K2 Pro |

## Passo 0: preparar a pasta de trabalho

```bash
mkdir -p ~/Projects/Orcaslicer/{apps,backups,downloads}
cd ~/Projects/Orcaslicer
git clone https://github.com/jglerner/OrcaSlicer_Plugin_Lab.git
```

## Passo 1: baixar a nightly (ao lado da 2.4.2)

> **Não desinstale a 2.4.2.** Um AppImage é um arquivo só, sem instalação no sistema: a
> estável e a nightly convivem lado a lado, e a 2.4.2 continua sendo a versão para imprimir
> no dia a dia. O que as duas compartilham é a pasta `~/.config/OrcaSlicer`, e é por isso
> que o passo 2 faz backup dela.

1. Abra <https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/nightly-builds>.
2. Baixe o **AppImage de Linux** (se houver opção por versão do Ubuntu, pegue a mais próxima da sua distro) para `~/Projects/Orcaslicer/apps/`.
3. Torne executável:
   ```bash
   chmod +x ~/Projects/Orcaslicer/apps/OrcaSlicer*nightly*.AppImage
   ```
   Se reclamar de FUSE: `sudo apt install libfuse2t64` (Debian 13 / Ubuntu 24.04+) ou `libfuse2` (Ubuntu 22.04).

**Neste Linux** os AppImages ficam em `~/Applications/orca/`, a convenção que já existia.
A nightly vai para o mesmo lugar: `~/Applications/orca/`. Os documentos, backups e
downloads ficam em `~/Projects/Orcaslicer/`.

> **Não abra a nightly ainda.** Primeiro o backup (passo 2).

## Passo 2: backup + instalação do plugin (um comando)

Com **todos** os Orca fechados:

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
scripts/install-support-fins.sh
```

O script:
1. faz backup de `~/.config/OrcaSlicer` em `~/Projects/Orcaslicer/backups/OrcaSlicer-<data>.tar.gz`;
2. baixa `support_fins_orca.py` da release `plugins-latest` para `~/Projects/Orcaslicer/downloads/` e anota versão e SHA-256 em `SHA256SUMS.txt`;
3. copia o arquivo para `~/.config/OrcaSlicer/orca_plugins/SupportFins/`.

Flatpak ou outra pasta: `ORCA_DATA_DIR="/caminho/para/OrcaSlicer" scripts/install-support-fins.sh`.

**Alternativa manual:** abra a nightly e use **Plugins ▸ ▾ Browse plugins ▸ Install local plugin**,
apontando para o `.py` baixado.

## Passo 3: ativar o plugin

1. Abra a **nightly** pelo lançador:
   ```bash
   ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab/scripts/orca-nightly.sh
   ```
   Abrindo o AppImage direto numa sessão **Wayland**, a janela não aparece: o terminal mostra
   só `Gtk-WARNING ... gtk_window_set_titlebar()` e volta ao prompt. O lançador força X11
   (`GDK_BACKEND=x11`), desliga a aceleração do WebKit (`WEBKIT_DISABLE_DMABUF_RENDERER=1`,
   `WEBKIT_DISABLE_COMPOSITING_MODE=1`) e grava a saída em `~/Projects/Orcaslicer/runs/`.
2. Menu principal ▸ **Plugins**. O "Support Fins" aparece como *Inactive*.
3. Marque **Activate**. Expanda a linha e confira se a capability *Support Fins* (tipo slicing pipeline) também está marcada.
4. Na primeira ativação, o `uv` do Orca baixa `numpy` e `mini-racer`, o que pode levar um tempo. Se der erro, veja a aba **Diagnostics**.

## Passo 4: adicionar o plugin ao perfil de processo

**Só ativar o plugin não faz nada.** O perfil de processo precisa referenciar o plugin:

1. Painel de processo ▸ modo **Advanced**.
2. **Others ▸ Slicing Pipeline Plugin ▸ Add plugin ▸ Support Fins**.
3. **Salve o perfil.** Sugestão: duplique o perfil da K2 Pro e salve como `K2 Pro – 0.20 – Fins`, para não mexer no perfil normal.

> Um perfil que referencia o plugin **não fatia** se o plugin estiver desativado ou ausente (o
> Orca mostra o aviso "missing plugin"). Isso também vale ao abrir esse perfil na 2.4.2.

## Passo 5: primeiro fatiamento

1. Peça de teste com overhang claro. Sugestão: o `angle-coupon.stl` do próprio projeto ([download](https://github.com/gittrahan/support-fins/raw/main/web/calibration/angle-coupon.stl)) ou um suporte em L inclinado.
2. Na peça: **Enable support = OFF**.
3. **Brim type = No brim** (veja a visão geral).
4. Fatie. Devem aparecer alguns **"Plugin permission request"**:
   - leitura de arquivos da biblioteca do próprio Python → **Yes**
   - `socket.__new__` → **Yes** (é comunicação interna do V8, não acessa a rede)
5. Vá ao **Preview** e confira se as fins aparecem.

## Passo 6: registrar resultados

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
scripts/collect-logs.sh "angle-coupon, 0.20mm, PLA"
git add logs/linux && git commit -m "Linux: primeiro teste Support Fins" && git push
```

Para acompanhar ao vivo enquanto fatia:

```bash
tail -f ~/.config/OrcaSlicer/log/python_*.log
```

### Checklist (preencher)

| # | Verificação | Resultado | Observação |
|---|---|---|---|
| 1 | Nightly abre e mostra o menu **Plugins** | ✅ abre (2.5.0) | só com `scripts/orca-nightly.sh` (Wayland) |
| 2 | Plugin aparece na lista com versão 0.1.0 | ✅ | aba Config mostra o JSON padrão |
| 3 | Ativação instala `numpy` + `mini-racer` sem erro | | |
| 4 | "Slicing Pipeline Plugin" aparece no perfil (Advanced ▸ Others) | ✅ | Support Fins adicionado ao `0.20mm Standard @Creality K2 Pro 0.4 nozzle` |
| 5 | Pedidos de permissão aparecem e são aceitos | | |
| 6 | Fins visíveis no Preview | ✅ | xyzCalibration_cube inclinado |
| 7 | Log `.jsonl` registra `N fin(s), M tine(s) on X layer(s)` | ✅ | `4 walls, 24 tines`, 141 camadas, 0,76 s |
| 8 | Peça com **Enable support ON** é ignorada (`skipped ...`) | | |
| 9 | Girar a peça + refatiar → fins acompanham | | |
| 10 | G-code enviado à K2 Pro e impresso | | |
| 11 | 1ª camada da base (pad) ok | | |
| 12 | Fins destacam limpas | | |
| 13 | 2.4.2 estável continua abrindo normalmente | | |

## Como voltar atrás

```bash
# remover só o plugin
rm -rf ~/.config/OrcaSlicer/orca_plugins/SupportFins
# restaurar toda a configuração (com o Orca fechado)
mv ~/.config/OrcaSlicer ~/.config/OrcaSlicer.nightly-teste
tar -xzf ~/Projects/Orcaslicer/backups/OrcaSlicer-<data>.tar.gz -C ~/.config
```

## Diário

### 2026-10-13: levantamento da máquina Linux

- Debian 13 (trixie).
- Única versão instalada: `~/Applications/orca/OrcaSlicer_Linux_AppImage_V2.3.0.AppImage`, **não a 2.4.2**. Sem atalho em `~/.local/share/applications`.
- `~/.config/OrcaSlicer`: 4,6 MB, último uso em 24/08. Já existe um `user_backup-v2.3.0/`,
  criado pelo próprio Orca ao atualizar de versão. A nightly deve criar outro igual, mas o
  backup do script é o que vale para restaurar.
- Decisão: manter a 2.3.0 como estava e pôr a nightly ao lado, em `~/Applications/orca/`.

### 2026-10-13: escolha do arquivo da nightly

- Arquivo: `OrcaSlicer_Linux_AppImage_Ubuntu2404_nightly.AppImage` (x86_64, 204 MB).
  sha256 publicado: `b5f4b191b740a1e14cfb96748aa21b4cd68d96f32a577dd085a310fbf5d60b10`.
- Descartados: as variantes `aarch64` (ARM), `_belt` (impressoras de esteira), o Flatpak
  (usa outra pasta de configuração) e os utilitários `profile_validator` e `generate_system_cache`.
- O nome do arquivo é igual todo dia. Ele é salvo **com a data no nome**
  (`..._nightly-AAAAMMDD.AppImage`) para sabermos qual build foi testado.

### 2026-10-13 09:50: download, backup e instalação

- Nightly: `~/Applications/orca/OrcaSlicer_Linux_AppImage_Ubuntu2404_nightly-20261013.AppImage`, sha256 **OK**.
- Backup: `~/Projects/Orcaslicer/backups/OrcaSlicer-20261013-095038.tar.gz`.
- Plugin instalado em `~/.config/OrcaSlicer/orca_plugins/SupportFins/`, versão 0.1.0, sha256 `65df17fa…963f`.
- **Observação:** o sha256 do plugin mudou em relação ao download de teste feito horas antes
  (`e4c283f6…6e66`), mas a versão continua 0.1.0. A release `plugins-latest` é refeita a cada
  push no support-fins, e às 07:38 entrou o commit `a517023` ("Allow optional Sway depth…").
  O número de versão não identifica o build; **o sha256 identifica**. Para o macOS dar o mesmo
  resultado, ele precisa usar este mesmo arquivo. Se `plugins-latest` mudar antes, copiar o `.py`
  de `~/Projects/Orcaslicer/downloads/` do Linux para o Mac.

### 2026-10-13: primeira abertura da nightly

- Apareceu o aviso de migração "Bambu Cloud → Orca Cloud" (sincronização de perfis desde a 2.4.0).
  Os perfis daqui nunca foram sincronizados pela Bambu Cloud, então o aviso foi **ignorado**.
- Decisão: **não fazer login na Orca Cloud na nightly.** Um perfil com o plugin, se sincronizado,
  chegaria às outras instalações (por exemplo a 2.4.2 do Mac), que não têm o plugin, e lá o Orca
  bloqueia o fatiamento com o aviso "missing plugin".

### 2026-10-13 09:52–10:00: a nightly não abria (Wayland)

- Abrindo o AppImage direto, a janela não aparecia nem na 1ª nem na 2ª tentativa. O terminal mostrava só:
  ```
  Gtk-WARNING **: gtk_window_set_titlebar() called on a realized window
  Gdk-WARNING **: .../gdk/wayland/gdkcursor-wayland.c:251 cursor image size (45x45) not an integer multiple of scale (2)
  ```
- Solução: fechar qualquer processo que tivesse sobrado (`pkill -f orca-slicer`) e abrir com
  `GDK_BACKEND=x11 WEBKIT_DISABLE_DMABUF_RENDERER=1 WEBKIT_DISABLE_COMPOSITING_MODE=1`.
  **Abriu, versão 2.5.0.** Ainda não foi isolado qual das três variáveis é a necessária.
- Criado o `scripts/orca-nightly.sh` para não precisar digitar as variáveis toda vez.
- Checklist: item 1 (nightly abre) ✅, com a ressalva do Wayland.

### 2026-10-13: plugin na janela Plugins

- Support Fins listado, **versão 0.1.0**, inicialmente *Inactive*.
- A aba **Config** mostra o JSON padrão do plugin (`apply_to: no-supports`, `bed_pad: true`,
  `coverage: 0.5`, `enabled: true`, `tine_density: 0`, `tines: true`), sinal de que o Orca carregou
  o arquivo e leu o `get_default_config()`.
- Confusão comum: as fins **não** aparecem em Support ▸ Type (que só tem Normal e Tree). O caminho
  certo é o menu **Plugins** mais **Others ▸ Slicing Pipeline Plugin** no perfil de processo.

### 2026-10-13: primeiras descobertas (antes de ver o log do plugin)

**1. As camadas só vão até 0,14 mm.** A primeira hipótese (impressora com bico 0,2) foi
**descartada**: a impressora já é *Creality K2 Pro 0.4 nozzle*, com limites de camada de
0,08 a 0,32 mm (print da aba Extruder). Nos perfis de sistema da nightly, o padrão dessa
impressora é `0.20mm Standard @Creality K2 Pro 0.4 nozzle`, então 0,20 mm deveria estar
disponível. *Falta saber onde o 0,14 aparece* (lista de perfis de processo, campo Layer height
ou régua do Preview).

**2. Cubo com faces a 45° → "pouca superfície de contato" + "first layer empty".**
Reproduzido fora do Orca com o mesmo motor (CLI do support-fins, cubo de 20 mm):

| Pose do cubo | Resultado do motor |
|---|---|
| 0° (em pé) | 0 fins, 0 tines (nada a suportar) |
| **45° em X (apoiado numa aresta)** | **0 fins, 0 tines**, `overhangRegions: 0`, só a base (pad) |
| 45° em X + 35,26° em Y (apoiado num vértice) | 0 fins, 0 tines |
| 30° ou 60° em X | **2 fins, 8 tines** |
| 45° em X com limiar de overhang em 50° | 4 fins, 16 tines |

- Com o cubo a 45°, as faces de baixo estão **exatamente no limiar de 45°** do motor, que por isso
  não as considera overhang e não gera fins. O motor ainda devolve a base (pad), que o plugin
  deveria colocar na 1ª camada.
- O erro "One object has an empty first layer and can't be printed" é do **próprio Orca**
  (`GCode.cpp`). Ele aparece quando a 1ª camada não tem extrusão, que é o caso de um cubo
  apoiado numa aresta ou num vértice (o contato com a mesa é uma linha ou um ponto).
- Se a base tivesse sido adicionada, a 1ª camada não estaria vazia. Então o mais provável é que
  **o plugin não rodou nesse fatiamento**: ou ainda não estava em *Others ▸ Slicing Pipeline Plugin*
  do perfil, ou *Enable support* estava ligado, ou houve erro/permissão negada. O
  `support_fins_log.jsonl` e o `python_*.log` dizem qual foi.
- Peça de teste melhor: cubo girado **30° ou 60°** em X, que dá fins com certeza.

### 2026-10-13 15:05: ✅ primeiro fatiamento com fins

Peça: `xyzCalibration_cube.STL` inclinado (bounding box 40 × 53,6 × 53,6 mm). Perfil
`0.20mm Standard @Creality K2 Pro 0.4 nozzle` com Support Fins em *Others ▸ Slicing Pipeline Plugin*,
Generic PLA. Fatiou com **267 camadas de 0,20 mm** (topo em 53,40), então o "limite de 0,14 mm"
não apareceu nesse fatiamento.

Log do plugin (`support_fins_log.jsonl`), resumido:

| Campo | Valor | Leitura |
|---|---|---|
| `result` | `4 walls, 24 tines; 3 overhangs are too shallow for a fin this way up (tilt the part steeper)` | 4 fins com 24 tines; 3 regiões no limiar de 45° ficaram sem fin |
| `engine.overhangRegions` | 5 | |
| `engine.padTriangles` | 35 904 | a base (pad) foi gerada |
| `layers_touched` | 141 | fins de z = 0,1 a 17,5 mm e de 24,3 a 34,7 mm |
| `frame_scale_vs_nominal` | [1.0, 0.99999999] | o plugin alinhou as fins com a peça sem erro de escala |
| `elephant_foot` | [0.15, 1] | compensação de 0,15 mm aplicada à 1ª camada das fins |
| `seconds` | 0,762 | tempo do plugin por objeto |

Observações:
- O aviso do Orca *"It seems object … has floating regions. Please re-orient the object or enable
  support generation"* é **não crítico** e vem do verificador de suporte do próprio Orca
  (`PrintObject::generate_support_material`), que roda porque o suporte está desligado. É esperado
  com fins, e coincide com as 3 regiões que o plugin informou como rasas demais.
- **Brim:** a lista de tipos de linha mostra *Brim* (1 min 12 s, 0,44 g). É o Auto brim em volta
  da base das fins. Para a próxima, testar com *Brim type = No brim*.
- O erro "empty first layer" do cubo a 45° visto antes provavelmente aconteceu antes do plugin
  ser adicionado ao perfil. Com o plugin ativo, a base preenche a 1ª camada.

### 2026-10-13: 1ª impressão de teste (em andamento)

- Peça: o mesmo `xyzCalibration_cube` inclinado. Perfil 0.20mm Standard, Generic PLA.
- Mudanças em relação ao padrão: **infill mínimo** e **brim manual de 5 linhas**, em vez do Auto
  brim, para garantir que não descole da mesa. Fora isso, nada mudou.
- Avaliar: aderência da base (pad) na 1ª camada, fins inteiras até o topo, se as fins se soltam
  da peça e o acabamento das faces que ficaram apoiadas.
- Preview na camada 40 (8,00 mm): **3 fins** saem da base (pad) e sobem até a face inclinada; a
  base está cercada pelo brim. A 4ª fin do log é o conjunto de 24,3 a 34,7 mm, que nasce na própria
  peça e não na mesa. Enable support desligado; infill esparso caiu para 4,26 g.
- Estimativa do Orca: 49 min 19 s, 21,56 g (7,17 m). **Velocidades padrão do perfil**, de propósito; aumentar só num teste seguinte, mudando uma variável por vez.
- 15:26: impressão iniciada pelo Fluidd (`xyzCalibration_cube_PLA_49m19s.gcode`, 1,7 MB, 268 camadas
  na contagem do Fluidd). Bico 220 °C, mesa 50 °C, PA 0,038. O Gcode Preview do Fluidd mostra as 3 fins
  saindo da base, com o brim em volta, então o G-code carrega a geometria injetada pelo plugin.
- 15:32: 14%, camada 22/268 (Z 4,42 mm), sem problemas. Bico 220 °C, mesa 50 °C, câmara 32 °C,
  velocidade 129,7 mm/s, aceleração 12 000 mm/s² (do perfil). Previsão de término às 16:12.
- Camada 72 (14,4 mm), no Gcode Preview do Fluidd: as 3 fins aparecem como paredes finas
  (um laço estreito cada) **fora** da seção do cubo, ainda subindo até a face inclinada, que elas
  alcançam por volta de 17,5 mm. A seção do cubo mostra paredes, infill esparso, o entalhe da
  letra e uma faixa de preenchimento sólido junto à borda das fins.
- Camada 85 (17,0 mm), o ponto crítico: no Gcode Preview, as 3 fins são só pontas curtas encostadas
  na borda do cubo (a fase dos tines). Na câmera a peça está firme, com a face inclinada apoiada nas fins,
  e a base com o brim bem assentada na mesa. Sem descolamento visível.
- 54% (camada 120/268, Z 24,02 mm), 25 min 10 s decorridos. Restante: 21 min 16 s pelo Fluidd e
  24 min 8 s pelo fatiador, então a impressora está uns **3 min à frente** da estimativa do Orca, com
  aceleração de 12 000 mm/s² e SCV de 4 mm/s. A essa altura começa a 4ª fin (24,3 a 34,7 mm).
- Camada 185 (cerca de 37 mm, já acima de todas as fins), em foto: a face com o "X" saiu limpa; a base
  oval com o brim continua colada na mesa; por dentro aparece o infill mínimo, com alguns fios finos
  (stringing), normal com infill baixo. As fins ficam do outro lado da peça e não aparecem neste ângulo.
- 16:15: 99%, camada 265/268, Z 53,01 mm. **Tempo total de 49 min 49 s** contra 49 min 19 s estimados
  pelo Orca (só +30 s), e 7,39 m de filamento contra 7,17 m estimados. A vantagem de ~3 min vista no
  meio da impressão não se manteve: o fim (topo, camadas pequenas, tempo mínimo por camada) compensou.
  **A estimativa do Orca é confiável para a K2 Pro.**
- Câmera: cubo completo com as faces X, Y e Z visíveis, sobre a base com o brim, sem descolamento.
- Resultado: _(pendente: remoção das fins e acabamento)_
