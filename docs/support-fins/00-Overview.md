# Support Fins in OrcaSlicer: overview

> Source: [gittrahan/support-fins › plugins/orca](https://github.com/gittrahan/support-fins/tree/main/plugins/orca)
> (read at commit `99a375d`, 10 Oct 2026). Fin engine by Matthew Trahan, MIT license.

## What the plugin does

"Support fins" are thin breakaway walls that hold up overhangs instead of conventional supports.
They are the same fins the [printfins.com](https://printfins.com) website generates.

Orca's API **does not let a plugin add objects to the plate**, so the plugin works **at slicing
time** (the `Step.posSlice` step):

1. it reads the part as placed, exactly as Orca is about to slice it;
2. it runs the website's engine **unmodified** (the printfins.com JavaScript inside an embedded V8, `mini-racer`);
3. it cuts the fins at every layer height and **adds those outlines to the layer**. From there on
   Orca builds walls, infill and G-code as if the STL had come with fins.

### Practical consequences

| Behavior | Detail |
|---|---|
| Fins only show in **Preview** | In Prepare the part still has no fins |
| Which parts get fins | Only parts with **Enable support OFF**. With Orca supports on, the part is skipped |
| Part rotated or moved | Just slice again and the fins follow |
| Instances | All copies of one object share one set of fins |
| Status | Experimental: both the plugin and Orca's pipeline API |

## Requirements

| Item | Value |
|---|---|
| OrcaSlicer | **Nightly** (or a release > 2.4.2). **2.4.2 stable does not work** |
| Plugin type | `slicing-pipeline`, a single `.py` file with a PEP 723 header |
| Python | ≥ 3.12, bundled with Orca |
| Dependencies | `numpy>=2.0`, `mini-racer==0.14.1`, installed automatically by Orca's bundled `uv` on first activation (**needs internet**) |
| File | `support_fins_orca.py` (~158 KB in 0.1.0, ~203 KB in 0.7.759) from the [`plugins-latest`](https://github.com/gittrahan/support-fins/releases/tag/plugins-latest) release |

## Configuration (plugin **Config** tab, JSON)

### Plugin 0.7.759 and later: every engine option

Since **0.7.759** (19 Oct 2026, upstream [#340](https://github.com/gittrahan/support-fins/pull/340)) the
Config tab accepts **any key from the engine's `options.json`**, in engine units (a percent is
value / 100). Invalid keys or values **fail the slice** with the engine's message. Example:

```json
{"threshold": 44, "gap": 0.3, "padStyle": "sure", "cutout": "lattice"}
```

| Key | Values (default) | Set it from |
|---|---|---|
| `enabled` / `apply_to` | `true` / `"no-supports"` or `"all"` | plugin's own switches |
| `mode` | `"auto"` or `"full"` (auto) | `"full"` puts walls under every overhang Auto leaves bare |
| `threshold` | 30–70 ° (45); measured **up from the plate**: faces *shallower* than it get support, so **higher = more support** (46 supports 45° faces, 44 does not) | `angle-coupon` |
| `gap` | 0.1–0.4 mm (0.2) | `gap-coupon` (replaces the old PLA/PETG `material`; e.g. 0.3 for PETG) |
| `padStyle` | `off` / `auto` / `light` / `sure` (auto) | `pad-coupon` |
| `tines`, `tineDensity` | bool (true), 0–1 (0) | `grip-coupon` |
| `tineDir`, `pinDepth` | `horizontal`/`vertical`, 0.05–1 mm (0.3) | advanced |
| `coverage` | 0–1 (0.5) | `span-coupon` (wide faces) |
| `cutout` | `none`/`diamond`/`triangle`/`arch`/`lattice` (none) | `cutout-coupon` |
| `sway.on`, `sway.*` | off | tall parts |
| `plateOnly`, `longWalls` | false, true | advanced |

- `layerHeight` is **refused**: it always comes from Orca.
- Old keys still work: `tine_density` (= `tineDensity`) and `bed_pad: false` (= `padStyle: "off"`).
- The authoritative list is `plugins/shared/engine/options.json` in the support-fins repository.

### Plugin 0.1.0 (tested in Chapters 1 and 2)

Only these keys were read; defaults, same as the website:

```json
{"enabled": true, "apply_to": "no-supports", "coverage": 0.5, "tines": true, "tine_density": 0.0, "bed_pad": true}
```

This limitation was reported as [gittrahan/support-fins#253](https://github.com/gittrahan/support-fins/issues/253)
and fixed in 0.7.759 ([our copy of the issue and the response](issue-orca-plugin-options.md)).

### Versions and permission prompts

- From 0.7.x the plugin version is `0.7.<n>` and changes with every build that changes the plugin
  (upstream [#341](https://github.com/gittrahan/support-fins/pull/341)); 0.1.0 never changed between builds.
- Recent builds usually show **no** *Plugin permission request* prompts: the engine starts while the
  plugin loads, before Orca's checks are on (upstream [#342](https://github.com/gittrahan/support-fins/pull/342)),
  which matches what we saw on both systems.

## Where things live (`data_dir` = Orca configuration folder)

| | Linux | macOS |
|---|---|---|
| `data_dir` | `~/.config/OrcaSlicer` | `~/Library/Application Support/OrcaSlicer` |
| Plugin | `data_dir/orca_plugins/SupportFins/support_fins_orca.py` | same |
| Plugin log | `data_dir/orca_plugins/SupportFins/support_fins_log.jsonl` | same |
| Python log (tracebacks) | `data_dir/log/python_*.log` | same |
| Global plugin config | `data_dir/orca_plugins/config.json` | same |

> To confirm `data_dir` on any system: **Help ▸ Show Configuration Folder**.
> With Flatpak (Linux) the folder is `~/.var/app/<app-id>/config/OrcaSlicer`.

## ⚠️ Nightly and stable share the SAME configuration folder

Both open the same `data_dir`, so the nightly may convert profiles into a format an older stable
release can no longer read. **Back it up before opening the nightly for the first time** (the
scripts in this repository do that). Each chapter includes the step.

## K2 Pro notes

- **Brim:** "Auto brim" is decided from the part **without** fins and may add a brim around the fin pad. If you don't want it, use *Brim type = No brim*.
- **Layers 1–3 (fin pad):** the plugin approximates Orca's elephant-foot compensation. Watch the first layer on the first print.
- **Pressure Advance (decision of 13 Oct 2026):** PA lives **only in the K2 Pro `printer.cfg`**, with the
  calibrated value. In **every** filament profile, on Linux and macOS, *Enable pressure advance* stays
  **off**. That way any computer that slices produces the same result, because the printer is in charge.
- **Process profiles:** the plugin has to be added to **every process profile** you want to use with fins.

## Chapters

- [Chapter 1: Linux](01-Linux.md)
- [Chapter 2: macOS](02-macOS.md)
- [Chapter 3: calibrated settings with plugin 0.7.759](03-Calibrated-0.7.md)
- Upstream issue [gittrahan/support-fins#253](https://github.com/gittrahan/support-fins/issues/253): expose more engine options in the Orca plugin ([our copy](issue-orca-plugin-options.md))

The expectation was **no behavioral difference** between the two systems. Both chapters use the
same steps and the same results checklist so they can be compared side by side. **Result:
confirmed. The plugin produced identical fins on both systems.**
