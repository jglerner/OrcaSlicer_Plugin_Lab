# Capítulo 2: Support Fins no macOS

> Leia antes a [visão geral](00-Visao_Geral.md) e, se possível, o [capítulo de Linux](01-Linux.md).
> Os passos são os mesmos. Este capítulo só registra o que muda no Mac.
> Status: **aguardando o teste no Linux**.

## Ambiente de teste (preencher)

| Item | Valor |
|---|---|
| macOS / versão | |
| Chip | Apple Silicon (arm64) / Intel (x86_64): `uname -m` |
| OrcaSlicer estável instalado | 2.4.2 |
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

## Passo 2: backup + instalação do plugin (um comando)

Com **todos** os Orca fechados (⌘Q):

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
git pull
scripts/install-support-fins.sh
```

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

Se a 2.4.2 do Mac estiver logada na **Orca Cloud**, **não** faça login na nightly, ou crie
perfis com o plugin só com a sincronização desligada. Um perfil sincronizado que referencia o
Support Fins bloqueia o fatiamento na 2.4.2 ("missing plugin").

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

_(anote aqui, por data, o que aconteceu em cada teste)_
