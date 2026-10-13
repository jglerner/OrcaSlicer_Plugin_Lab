# OrcaSlicer Plugin Lab

Diário de experiências pessoais com o **sistema de plugins em Python do OrcaSlicer**:
o que foi instalado, como foi feito e o que aconteceu de fato em cada sistema.

- **Autor / testes:** J. Lerner
- **Impressora de referência:** Creality K2 Pro (Klipper), ver [k2-pro-klipper](https://github.com/jglerner/k2-pro-klipper)
- **Pasta de trabalho local:** `~/Projects/Orcaslicer/` (o mesmo caminho no Linux e no macOS)

## Ponto de partida importante

O sistema de plugins **não existe na versão estável 2.4.2**. Segundo o wiki oficial, ele está
disponível em "[Nightly builds](https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/nightly-builds)
ou releases maiores que **2.4.2**". Em 13/10/2026 a última estável ainda é a 2.4.2, então
todos os testes usam uma **nightly** instalada **ao lado** da estável.

## Experimentos

| # | Plugin | Origem | Linux | macOS |
|---|--------|--------|-------|-------|
| 1 | Support Fins (fins de suporte destacáveis do printfins.com) | [gittrahan/support-fins](https://github.com/gittrahan/support-fins/tree/main/plugins/orca) | [Capítulo 1](docs/support-fins/01-Linux.md) | [Capítulo 2](docs/support-fins/02-macOS.md) |

Comece por [Support Fins: visão geral](docs/support-fins/00-Visao_Geral.md).

## Estrutura

```
docs/support-fins/     visão geral + um capítulo por sistema operacional
scripts/               instalação, coleta de logs (Linux e macOS) e lançador da nightly (Linux)
logs/linux/, logs/macos/   logs e resultados copiados dos testes reais
plugins/support-fins/  cópia exata do plugin testado (mesmo sha256 nos dois sistemas)
projects/              projetos .3mf do Orca usados nos testes (mesma peça e mesmas configurações)
docs/support-fins/img/ fotos das impressões (linux/, macos/)
```

## Layout local sugerido (igual nos dois sistemas)

```
~/Projects/Orcaslicer/
├── OrcaSlicer_Plugin_Lab/      ← este repositório (git clone)
├── apps/                       ← nightly AppImage (Linux) / .dmg baixado (macOS)
├── backups/                    ← cópia da pasta de configuração do Orca antes de testar
└── downloads/                  ← arquivos de plugin baixados (com SHA-256 registrado)
```

## Licença

Documentação: MIT. Os plugins testados têm as licenças próprias deles (Support Fins: MIT).
