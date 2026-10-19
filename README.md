# OrcaSlicer Plugin Lab

A personal lab notebook for the **OrcaSlicer Python plugin system**: what was installed, how it
was done, and what actually happened on each operating system.

- **Author / tester:** J. Lerner
- **Reference printer:** Creality K2 Pro (Klipper), see [k2-pro-klipper](https://github.com/jglerner/k2-pro-klipper)
- **Local working folder:** `~/Projects/Orcaslicer/` (same path on Linux and macOS)
- **Language:** English (all documents in this repository)

## Important starting point

The plugin system **does not exist in the 2.4.2 stable release**. According to the official wiki
it is available in "[Nightly builds](https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/nightly-builds)
or releases greater than **2.4.2**". As of 13 Oct 2026 the latest stable release is still 2.4.2, so
every test uses a **nightly** build installed **alongside** any stable install.

## Experiments

| # | Plugin | Source | Linux | macOS |
|---|--------|--------|-------|-------|
| 1 | Support Fins (printfins.com breakaway support fins) | [gittrahan/support-fins](https://github.com/gittrahan/support-fins/tree/main/plugins/orca) | [Chapter 1](docs/support-fins/01-Linux.md) ✅ | [Chapter 2](docs/support-fins/02-macOS.md) ✅ fins identical to Linux |
| 1b | Support Fins 0.7.759: calibrated settings, Full coverage | upstream fix for [#253](https://github.com/gittrahan/support-fins/issues/253) | [Chapter 3](docs/support-fins/03-Calibrated-0.7.md) (planned) | — |

Start with the [Support Fins overview](docs/support-fins/00-Overview.md).

## Repository layout

```
docs/support-fins/       overview + one chapter per operating system + upstream issue
docs/support-fins/img/   print photos (linux/, macos/)
scripts/                 install, log collection (Linux and macOS) and nightly launcher (Linux)
logs/                    logs from real runs (linux/, macos/, compare-YYYYMMDD/)
plugins/support-fins/    exact copy of the plugin build that was tested (same sha256 on both OSes)
projects/                Orca .3mf projects used in the tests (same part, same settings)
```

## Suggested local layout (same on both systems)

```
~/Projects/Orcaslicer/
├── OrcaSlicer_Plugin_Lab/      ← this repository (git clone)
├── apps/                       ← nightly AppImage (Linux) / downloaded .dmg and app (macOS)
├── backups/                    ← copy of the Orca configuration folder taken before testing
└── downloads/                  ← downloaded plugin files (SHA-256 recorded in SHA256SUMS.txt)
```

## License

Documentation: MIT. The tested plugins keep their own licenses (Support Fins: MIT).
