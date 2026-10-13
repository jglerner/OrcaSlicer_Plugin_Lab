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
| OrcaSlicer nightly testado | (data e hash do build, em OrcaSlicer ▸ About) |
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
| 1 | Nightly abre e mostra o menu **Plugins** | | |
| 2 | Plugin aparece na lista com versão 0.1.0 | | |
| 3 | Ativação instala `numpy` + `mini-racer` sem erro | | |
| 4 | "Slicing Pipeline Plugin" aparece no perfil (Advanced ▸ Others) | | |
| 5 | Pedidos de permissão aparecem e são aceitos | | |
| 6 | Fins visíveis no Preview | | |
| 7 | Log `.jsonl` registra `N fin(s), M tine(s) on X layer(s)` (**mesmos números do Linux** para a mesma peça e o mesmo perfil?) | | |
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
