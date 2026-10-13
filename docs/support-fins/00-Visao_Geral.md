# Support Fins no OrcaSlicer: visão geral

> Fonte: [gittrahan/support-fins › plugins/orca](https://github.com/gittrahan/support-fins/tree/main/plugins/orca)
> (lido no commit `99a375d`, de 10/10/2026). Motor de fins de Matthew Trahan, sob licença MIT.

## O que o plugin faz

As "support fins" são aletas finas e destacáveis que sustentam overhangs no lugar dos
suportes convencionais. São as mesmas geradas pelo site [printfins.com](https://printfins.com).

A API do Orca **não deixa plugin acrescentar objetos na mesa**. Por isso o plugin age **no
fatiamento** (etapa `Step.posSlice`):

1. lê a peça já posicionada, do jeito que o Orca vai fatiá-la;
2. roda o motor do site **sem modificações** (o JavaScript do printfins.com dentro de um V8 embutido, o `mini-racer`);
3. corta as fins na altura de cada camada e **soma esses contornos à camada**. Daí em diante o
   Orca gera paredes, preenchimento e G-code como se fosse um STL que já viesse com fins.

### Consequências práticas

| Comportamento | Detalhe |
|---|---|
| As fins só aparecem no **Preview** | Na tela Prepare a peça continua sem fins |
| Quais peças recebem fins | Só as que têm **Enable support DESLIGADO**. Com suporte do Orca ligado, a peça é ignorada |
| Girou ou moveu a peça | Basta fatiar de novo e as fins acompanham |
| Instâncias | Todas as cópias de um mesmo objeto usam o mesmo conjunto de fins |
| Status | Experimental: tanto o plugin quanto a API de pipeline do Orca |

## Requisitos

| Item | Valor |
|---|---|
| OrcaSlicer | **Nightly** (ou release > 2.4.2). A **2.4.2 estável não serve** |
| Tipo do plugin | `slicing-pipeline`, arquivo único `.py` com cabeçalho PEP 723 |
| Python | ≥ 3.12, embutido no Orca |
| Dependências | `numpy>=2.0`, `mini-racer==0.14.1`, instaladas sozinhas pelo `uv` do Orca na 1ª ativação (**precisa de internet**) |
| Arquivo | `support_fins_orca.py` (~158 KB), da release [`plugins-latest`](https://github.com/gittrahan/support-fins/releases/tag/plugins-latest) |

## Configuração (aba **Config** do plugin, em JSON)

Padrões, iguais aos do site:

```json
{
  "enabled": true,
  "apply_to": "no-supports",
  "coverage": 0.5,
  "tines": true,
  "tine_density": 0.0,
  "bed_pad": true
}
```

- `apply_to`: `"no-supports"` respeita a opção de suporte de cada peça; `"all"` ignora essa opção.
- `coverage` e `tine_density`: de 0 a 1, iguais aos sliders do site.
- `bed_pad`: base (pad) na mesa que une as fins.

## Onde ficam as coisas (`data_dir` = pasta de configuração do Orca)

| | Linux | macOS |
|---|---|---|
| `data_dir` | `~/.config/OrcaSlicer` | `~/Library/Application Support/OrcaSlicer` |
| Plugin | `data_dir/orca_plugins/SupportFins/support_fins_orca.py` | idem |
| Log do plugin | `data_dir/orca_plugins/SupportFins/support_fins_log.jsonl` | idem |
| Log do Python (tracebacks) | `data_dir/log/python_*.log` | idem |
| Config global de plugins | `data_dir/orca_plugins/config.json` | idem |

> Para confirmar o `data_dir` em qualquer sistema: **Help ▸ Show Configuration Folder**.
> No Flatpak (Linux) a pasta fica em `~/.var/app/<id-do-app>/config/OrcaSlicer`.

## ⚠️ A nightly e a estável usam a MESMA pasta de configuração

As duas abrem o mesmo `data_dir`, então a nightly pode converter perfis para um formato que a
2.4.2 depois não lê. **Antes de abrir a nightly pela primeira vez, faça backup** (os scripts
deste repositório fazem isso). Cada capítulo tem o passo.

## Cuidados para a K2 Pro

- **Brim:** o "Auto brim" é decidido olhando a peça **sem** fins e pode colocar brim em volta da base das fins. Se não quiser, use *Brim type = No brim*.
- **Camadas 1–3 (base das fins):** o plugin tenta compensar o elephant foot do Orca de forma aproximada. Observe a 1ª camada na primeira impressão.
- **Perfis de processo:** o plugin precisa ser adicionado **em cada perfil de processo** que você for usar com fins.

## Capítulos

- [Capítulo 1: Linux](01-Linux.md)
- [Capítulo 2: macOS](02-macOS.md)

A expectativa é que **não haja diferenças** de comportamento entre os dois sistemas. Os
capítulos têm os mesmos passos e a mesma tabela de resultados, para facilitar a comparação.
