# Capítulo 2: Support Fins no macOS

> Leia antes a [visão geral](00-Visao_Geral.md) e, se possível, o [capítulo de Linux](01-Linux.md).
> Os passos são os mesmos. Este capítulo só registra o que muda no Mac.
> Status: **aguardando o teste no Linux**.

## Ambiente de teste (preencher)

| Item | Valor |
|---|---|
| macOS / versão | macOS 27.0.1 (build 26A434), Mac mini |
| Chip | Apple Silicon (`arm64`) |
| OrcaSlicer estável instalado | **nenhum neste Mac mini** (nada em `/Applications/Orca*` e sem `~/Library/Application Support/OrcaSlicer`) |
| OrcaSlicer nightly testado | **2.5.0-dev** (`CFBundleShortVersionString`), `.dmg` de 13/10/2026 17:52 UTC, sha256 `7fcc7776…09ba` |
| Plugin: versão / sha256 | (o script de instalação imprime os dois) |
| Perfil de impressora | Creality K2 Pro |

## O que muda em relação ao Linux

| | Linux | macOS |
|---|---|---|
| Pasta de configuração | `~/.config/OrcaSlicer` | `~/Library/Application Support/OrcaSlicer` |
| Nightly | AppImage em `apps/` | `.dmg`; o app precisa ser **renomeado** (veja o passo 1) |
| Gatekeeper | n/a | a nightly não é assinada; pode exigir liberar a quarentena |
| `mini-racer` | wheel linux-x64 | wheel macOS arm64 ou x64, escolhida automaticamente pelo `uv` |
| Scripts | os mesmos | os mesmos (detectam o sistema sozinhos) |

## Passo 0: preparar a pasta de trabalho

```bash
mkdir -p ~/Projects/Orcaslicer/{apps,backups,downloads}
cd ~/Projects/Orcaslicer
git clone https://github.com/jglerner/OrcaSlicer_Plugin_Lab.git
```

## Passo 1: instalar a nightly SEM substituir a 2.4.2

1. Em <https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/nightly-builds>, baixe **`OrcaSlicer_Mac_universal_nightly.dmg`** (universal: serve para Apple Silicon e Intel) para `~/Projects/Orcaslicer/apps/`. **Não** use o `OrcaSlicer_profile_validator_Mac_universal_nightly.dmg`, que é um utilitário. Confira o sha256 com `shasum -a 256` contra o valor da página.
2. Abra o `.dmg`. **Não arraste direto para Aplicativos**: o app tem o mesmo nome `OrcaSlicer.app` e substituiria a 2.4.2. Arraste para `~/Projects/Orcaslicer/apps/` e renomeie:
   ```bash
   mv ~/Projects/Orcaslicer/apps/OrcaSlicer.app ~/Projects/Orcaslicer/apps/OrcaSlicer-Nightly.app
   ```
3. Se o macOS disser que o app "está danificado" ou que "não pode ser aberto":
   ```bash
   xattr -dr com.apple.quarantine ~/Projects/Orcaslicer/apps/OrcaSlicer-Nightly.app
   ```
   (ou Ajustes do Sistema ▸ Privacidade e Segurança ▸ **Abrir Mesmo Assim**).

> **Não abra a nightly ainda.** Primeiro o backup (passo 2).

## Referência do Linux (o que comparar)

O Capítulo 1 terminou com o plugin aprovado. Para o comparativo valer, o Mac usa **o mesmo
arquivo do plugin** e **o mesmo projeto**:

| Item | Linux (referência) |
|---|---|
| Nightly | 2.5.0, build de 13/10/2026 |
| Plugin | 0.1.0, sha256 `65df17faabfbd870918b3f0fdc95e460229241afb996e2fb8ab830871706963f` (cópia em `plugins/support-fins/`) |
| Projeto | `projects/xyzCalibration_cube-fins.3mf` (peça inclinada + perfil 0.20mm Standard + Support Fins + brim de 5 linhas + infill mínimo) |
| Log do motor | `4 walls, 24 tines; 3 overhangs are too shallow…`, `overhangRegions: 5`, `padTriangles: 35904`, `layers_touched: 141` |
| Fatiamento | 267 camadas de 0,20 mm, estimativa de 49 min 19 s, 21,56 g |
| Impressão | 49 min 49 s reais, 7,39 m; fins saem com a mão; cicatriz na face apoiada |

**Critério de "sem diferença":** com o mesmo `.3mf` e o mesmo sha256, o `support_fins_log.jsonl`
do Mac deve repetir `4 walls, 24 tines`, `layers_touched: 141` e as mesmas áreas por camada, e o
Orca deve estimar o mesmo tempo e o mesmo peso.

## Passo 2: backup + instalação do plugin (um comando)

Com **todos** os Orca fechados (⌘Q):

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
git pull
PLUGIN_FILE="$(ls plugins/support-fins/support_fins_orca-*.py | head -1)" scripts/install-support-fins.sh
```

Isso instala **a mesma cópia** usada no Linux, em vez de baixar o `plugins-latest`, que pode ter mudado.

O resultado é o mesmo do Linux, só que em `~/Library/Application Support/OrcaSlicer`.
Compare o **sha256** com o registrado no teste de Linux: deve ser igual se a release
`plugins-latest` não tiver mudado nesse meio-tempo. Se mudou, anote; a release é
substituída a cada push no repositório do support-fins.

## Passos 3 a 5: idênticos ao Linux

Siga os passos 3, 4 e 5 do [capítulo 1](01-Linux.md#passo-3-ativar-o-plugin). A única
diferença é como abrir a nightly:

```bash
open ~/Projects/Orcaslicer/apps/OrcaSlicer-Nightly.app
```

No Mac, o menu **Plugins** pode ficar na barra de menus do sistema em vez de dentro da janela.

**Orca Cloud:** a 2.4.2 do Mac **não** está logada (confirmado em 13/10/2026). Se aparecer o
aviso de migração Bambu Cloud → Orca Cloud, é só ignorar. Também não faça login na nightly:
um perfil sincronizado que referencia o Support Fins bloquearia o fatiamento numa instalação
sem o plugin ("missing plugin").

Itens a observar com mais atenção no Mac:
- **Ativação:** o `uv` precisa achar a wheel do `mini-racer==0.14.1` para o seu chip. Se falhar, a aba **Diagnostics** e o `python_*.log` mostram o motivo.
- **Pedidos de permissão:** podem aparecer em número diferente do Linux. Anote quantos e quais foram.

## Passo 6: registrar resultados

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
scripts/collect-logs.sh "angle-coupon, 0.20mm, PLA"
git add logs/macos && git commit -m "macOS: primeiro teste Support Fins" && git push
```

Ao vivo:

```bash
tail -f ~/Library/Application\ Support/OrcaSlicer/log/python_*.log
```

### Checklist (preencher; mesma numeração do Linux)

| # | Verificação | Resultado | Igual ao Linux? |
|---|---|---|---|
| 1 | Nightly abre e mostra o menu **Plugins** | ✅ 2.5.0-dev | ⚠️ não: 1ª abertura congelou o Mac em tela cheia (reboot) |
| 2 | Plugin aparece na lista com versão 0.1.0 | ✅ | sim (menu na barra do sistema) |
| 3 | Ativação instala `numpy` + `mini-racer` sem erro | ✅ (arm64) | sim |
| 4 | "Slicing Pipeline Plugin" aparece no perfil (Advanced ▸ Others) | ✅ | sim (só no modo avançado) |
| 5 | Pedidos de permissão aparecem e são aceitos | ➖ nenhum apareceu | igual ao Linux |
| 6 | Fins visíveis no Preview | ✅ | sim |
| 7 | Log `.jsonl` registra `N fin(s), M tine(s) on X layer(s)` (**mesmos números do Linux** para a mesma peça e o mesmo perfil?) | ✅ `4 walls, 24 tines`, 141 camadas | **idêntico**, camada por camada |
| 8 | Peça com **Enable support ON** é ignorada | | |
| 9 | Girar a peça + refatiar → fins acompanham | | |
| 10 | G-code enviado à K2 Pro e impresso | | |
| 11 | 1ª camada da base (pad) ok | | |
| 12 | Fins destacam limpas | | |
| 13 | 2.4.2 estável continua abrindo normalmente | | |

O item 7 é o melhor teste de "não deve haver diferença": a mesma peça, o mesmo perfil e a
mesma versão do plugin devem dar exatamente a mesma contagem de fins, tines e camadas.

## Como voltar atrás

```bash
rm -rf ~/Library/Application\ Support/OrcaSlicer/orca_plugins/SupportFins
# restaurar toda a configuração (com o Orca fechado)
mv ~/Library/Application\ Support/OrcaSlicer ~/Library/Application\ Support/OrcaSlicer.nightly-teste
tar -xzf ~/Projects/Orcaslicer/backups/OrcaSlicer-<data>.tar.gz -C ~/Library/Application\ Support
```

## Diário

### 2026-10-13 16:44–16:56: levantamento do Mac

- Mac mini, macOS 27.0.1, Apple Silicon (`arm64`).
- `~/Projects/Orcaslicer/{apps,backups,downloads}` criados e o repositório clonado em
  `~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab` (branch `claude/sweet-ritchie-ogkhg8`).
- **Nenhum OrcaSlicer instalado** e **nenhuma pasta de configuração**: o Orca nunca rodou neste
  Mac. Consequências:
  - não há perfis a proteger, então o backup é só formalidade;
  - a ordem dos passos muda: **abrir a nightly uma vez** (para criar a configuração e escolher a
    K2 Pro 0.4 no assistente), **fechar**, e só então rodar `install-support-fins.sh`, que exige
    que a pasta de configuração exista.
- Observação: no zsh (padrão do macOS), um `ls` com padrão sem correspondência aborta a linha
  inteira (`zsh: no matches found`). Nos comandos deste capítulo, evitar curingas soltos.
- **Decisão:** sem nenhum Orca neste Mac, a **nightly é a única instalação**. Ela fica mesmo assim em
  `~/Projects/Orcaslicer/apps/OrcaSlicer-Nightly.app`, para manter o mesmo layout do Linux e não ocupar
  o nome `OrcaSlicer.app` em `/Applications`, reservado para uma estável futura.

### 2026-10-13: download da nightly

- `~/Projects/Orcaslicer/apps/OrcaSlicer_Mac_universal_nightly-20261013.dmg`, 379 451 701 bytes.
- sha256 `7fcc77764331d08f4f3638205bf094522ab741f2ca26b8ddce07118b504c09ba`, conferido com um
  segundo download independente (mesmo hash).
- ⚠️ **Não é o mesmo build da nightly usada no Linux.** O `.dmg` foi republicado às 17:52 UTC,
  depois da lista de assets copiada de manhã (que mostrava `43ff09ad…` e 363 MB), então houve
  pelo menos um build novo no mesmo dia. Para o comparativo isso significa: Orca de builds
  diferentes nos dois sistemas. O que precisa ser idêntico é o **plugin** (sha256) e o **projeto**;
  se os resultados divergirem, a diferença de build do Orca é a primeira suspeita.

### 2026-10-13: app copiado como `OrcaSlicer-Nightly.app`

- O `.dmg` contém `OrcaSlicer.app` e um atalho `Applications`. Os checksums internos do `.dmg` foram verificados.
- Copiado para `~/Projects/Orcaslicer/apps/OrcaSlicer-Nightly.app` e quarentena removida (`xattr -dr`).
- **macOS 27:** `hdiutil attach/detach` funciona, mas avisa que está *deprecated*. O substituto
  indicado pelo próprio sistema é:
  ```bash
  diskutil image attach --mountOptions nobrowse --mountPoint /tmp/orca-dmg OrcaSlicer_Mac_universal_nightly-AAAAMMDD.dmg
  diskutil eject /tmp/orca-dmg
  ```
- Versão do app: **2.5.0-dev**, a mesma série do Linux (2.5.0).

### 2026-10-13: assistente inicial e condições do comparativo

- Assistente: **Stealth Mode ligado** (desliga só os recursos de nuvem; plugins locais e o `uv`
  não são afetados), **Bambu Network Plugin não instalado** (não serve para a K2 Pro), **sem login**
  na Orca Cloud.
- **Condições iguais às do Linux ("banana com banana"):** mesma peça e mesma pose, perfil
  `0.20mm Standard @Creality K2 Pro 0.4 nozzle`, Generic PLA a **220 °C**, **infill de 6 %**, **brim Auto de 5 mm** (no Linux também foi 220 °C;
  os 240 °C vistos no início são da purga do CFS), mesa 50 °C, infill mínimo, brim de 5 linhas,
  Support Fins com a config padrão. A única variável é o sistema operacional (e, sem querer, o build
  da nightly).
- Teste de temperatura (torre) fica **depois** do comparativo.

### 2026-10-13 17:10–17:26: ⚠️ primeira abertura travou o Mac (reboot forçado)

- A nightly foi aberta pelo `open`. O assistente foi concluído (K2 Pro 0.4; a configuração em
  `~/Library/Application Support/OrcaSlicer` foi criada às 17:10–17:13). Por volta das 17:18 a
  janela foi posta em **tela cheia** (botão verde) e a tela congelou, cobrindo até a barra de
  tarefas. ⌘Tab e ⌥⌘Esc não resolveram: **reboot forçado**.
- Depois do reboot, o macOS **reabriu o Orca sozinho** ("Restored"). Cuidado com isso.
- **Análise do log** (`debug_Tue_Oct_13_17_10_45_90742.log.0`, 13 MB):
  - O log termina às **17:25:36** com a tarefa periódica `process_ui_task{type:Backup}` a cada 10 s,
    rodando na thread principal (a da interface). Ou seja, **o laço de eventos do Orca continuava
    vivo até o reboot**: o app não estava travado. O congelamento foi na **tela/janela em tela cheia**
    (servidor de janelas do macOS 27 ou a parte gráfica), não no processamento do Orca.
  - As linhas mais repetidas (`set_printer_hold_alias`, `select_preset`) são o carregamento normal
    dos perfis de todos os fabricantes: centenas de linhas, não um laço infinito.
  - Erros que valem nota:
    - `get_version_from_json: parse …/OrcaSlicer-Nightly.app/Contents/Resources/profiles/OrcaFilamentLibrary.json`
      e `…/Creality.json`: *"unexpected end of input"* na linha 1. **Investigado: inofensivo.** Esses
      `.json` não existem no app (o app tem 779 MB e está completo). A nightly 2.5 distribui os perfis
      dos fabricantes como **cache `.opc`** (`Resources/profiles/<Fabricante>.opc`), e a função
      `installable_cache_version` (`src/libslic3r/utils.cpp`) chama `get_version_from_json` no `.json`
      ausente, que registra esse erro e segue em frente. É ruído de log.
    - `3DconnexionClient` ausente e `Unsupported printer type: Moonraker Printer`: inofensivos.
- Lições: **não usar tela cheia** com a nightly neste Mac; abrir pelo Terminal
  (`…/OrcaSlicer-Nightly.app/Contents/MacOS/OrcaSlicer`) para ver as mensagens ao vivo.

### 2026-10-13 17:41: plugin instalado, depois trocado pela cópia do Linux

- Configuração salva em `~/Projects/Orcaslicer/backups/OrcaSlicer-20261013-174129.tar.gz`.
- O `plugins-latest` baixado veio com **sha256 `d4e90d31…c515`**, diferente do Linux (`65df17fa…`),
  com a mesma versão 0.1.0. Comparação: o código Python é idêntico; mudou só o motor JS embutido
  (commits do support-fins de 13/10 à tarde: campo "Nozzle size" e altura de camada máxima de 0,6 mm).
- Para manter "banana com banana", a cópia exata do Linux foi publicada em
  `plugins/support-fins/support_fins_orca-65df17fa.py` e reinstalada com `PLUGIN_FILE=…`.
- Menu **Plugins** encontrado; Support Fins **Activated** (numpy + mini-racer instalados pelo `uv`).
  No Mac, o menu fica na barra de menus do sistema, não dentro da janela como no Linux. O painel de processo
  abriu no modo simples: a seção *Slicing Pipeline Plugin* só aparece no modo **Advanced**.
- 18:02: plugin reinstalado a partir da cópia do repositório: **sha256 `65df17fa…963f`** ✅, o mesmo
  arquivo usado no Linux.
- 18:09: painel de processo estava no **modo simples** (sem a aba Speed; Others só com Skirt, Brim, Special
  mode e Fuzzy skin). A seção *Slicing Pipeline Plugin* só aparece com a chave do modo avançado ligada.
  Brim já estava Auto/5 mm, igual ao Linux. Infill a ajustar para 6 %.
- Print de tela no Mac com teclado Bluetooth UGreen: os atalhos ⇧⌘3/⇧⌘4 não funcionaram. Alternativa
  pelo Terminal: `screencapture -T 5 ~/Desktop/orca.png`.
- Projeto do Linux salvo como `.3mf` e passado ao Mac (por WhatsApp), depois aberto na nightly do Mac. Assim
  peça, pose e configurações vêm do mesmo arquivo. (A cópia deve ir também para `projects/` no repositório.)

### 2026-10-13: ✅ comparativo do fatiamento Linux × macOS (o mesmo `.3mf`, o mesmo plugin `65df17fa`)

Logs completos e script de comparação em `logs/compare-20261013/`.

| Campo | Linux (Debian 13, x86_64) | macOS (27.0.1, arm64) | |
|---|---|---|---|
| `result` | 4 walls, 24 tines; 3 overhangs too shallow | idem | ✅ igual |
| `part_size_mm` | [40.0, 53.626, 53.626] | idem | ✅ mesma peça, mesma pose |
| `engine` (regiões, triângulos, tines, pad…) | 5 / 2768 / 24 / 35904 | idem | ✅ igual |
| `layers` (141 pares z, área) | — | — | ✅ **idênticos nas 141 camadas** (4 casas decimais) |
| `elephant_foot` | [0.15, 1] | idem | ✅ |
| `frame_scale` Y | 0,9999999951 | 0,9999999937 | diferença relativa de 1,4 × 10⁻⁹, menos de 0,1 nanômetro em 53 mm: arredondamento de ponto flutuante (CPU/compilação diferentes), irrelevante |
| Estimativa do Orca | 49 min 19 s, 7,17 m | **49 min 19 s, 7,17 m** | ✅ igual |
| `seconds` | 0,762 | 1,405 | Mac ~1,8× mais lento nesta medida (1ª execução do V8 na sessão; medir de novo) |

**Conclusão: o plugin gera exatamente as mesmas fins no Linux e no macOS** ("banana com banana"),
apesar de os builds da nightly serem diferentes (o `.dmg` foi republicado no mesmo dia). A única
diferença real até aqui é a de ambiente: o congelamento em tela cheia no macOS 27.
- Ao fatiar no Mac, **nenhum pedido de permissão** do Orca apareceu, só o aviso não crítico
  *"floating regions"* do próprio Orca, exatamente como no Linux. O README do plugin previa pedidos
  (leitura de arquivos do Python, `socket.__new__`). Possível explicação: o motor V8 é iniciado no
  carregamento do plugin, quando o controle de permissões ainda está desligado (comentário em
  `_engine_ctx()`), então as operações que gerariam pedido acontecem antes. Não verificado.

### 2026-10-13 18:36: impressão do G-code fatiado no Mac (em andamento)

- Mesmo nome de arquivo (`xyzCalibration_cube_PLA_49m19s.gcode`), enviado às 18:36. Às 18:45: 17%,
  camada 29/268 (Z 5,80 mm), bico 220,5/220 °C, mesa 50 °C, câmara 35 °C, término previsto às 19:23.
  O Gcode Preview do Fluidd mostra as fins saindo da base, como no Linux.
- **Diferenças vistas no Fluidd em relação à impressão do Linux** (não vêm do plugin, e sim dos perfis
  de filamento ou de troca de filamento):

  | | Linux (15:26) | Mac (18:37) |
  |---|---|---|
  | Pressure Advance / Smooth time | 0,038 s / 0,038 s | **0,04 s / 0,04 s** |
  | Purga do CFS: `flush_volume` / `flush_len` | 354 / 223,75 mm | **60 / 101,25 mm** |

  O PA de 0,038 no Linux provavelmente veio de um perfil de filamento personalizado herdado da 2.3.0;
  no Mac, com instalação nova, ficou o valor do Generic PLA do sistema. A purga menor deve vir dos
  "Flushing volumes" do projeto ou da cor do filamento anterior. **A geometria (fins) é idêntica; o
  PA ligeiramente diferente pode mudar um pouco o acabamento.**
- Resultado: _(pendente)_
