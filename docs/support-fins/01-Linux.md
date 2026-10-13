# Capítulo 1: Support Fins no Linux

> Leia antes a [visão geral](00-Visao_Geral.md). Status: **aguardando o primeiro teste**.

## Ambiente de teste (preencher)

| Item | Valor |
|---|---|
| Distribuição / versão | |
| Desktop (X11/Wayland) | |
| OrcaSlicer estável instalado | 2.4.2, AppImage (instalada pelas Releases do GitHub) |
| OrcaSlicer nightly testado | (data e hash do build, em Help ▸ About) |
| Plugin: versão / sha256 | (o script de instalação imprime os dois) |
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
   Se reclamar de FUSE: `sudo apt install libfuse2` (Ubuntu 22.04) ou `libfuse2t64` (Ubuntu 24.04+).

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

1. Abra a **nightly**:
   ```bash
   ~/Projects/Orcaslicer/apps/OrcaSlicer*nightly*.AppImage
   ```
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
| 1 | Nightly abre e mostra o menu **Plugins** | | |
| 2 | Plugin aparece na lista com versão 0.1.0 | | |
| 3 | Ativação instala `numpy` + `mini-racer` sem erro | | |
| 4 | "Slicing Pipeline Plugin" aparece no perfil (Advanced ▸ Others) | | |
| 5 | Pedidos de permissão aparecem e são aceitos | | |
| 6 | Fins visíveis no Preview | | |
| 7 | Log `.jsonl` registra `N fin(s), M tine(s) on X layer(s)` | | |
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

_(anote aqui, por data, o que aconteceu em cada teste)_
