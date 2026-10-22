# Chapter 3: calibrated settings with plugin 0.7.759 (planned)

> Status: **in progress** (Linux). Read the [overview](00-Overview.md) (section *Plugin 0.7.759 and later*) first.

## Why

Chapters 1 and 2 showed the plugin works and is identical on Linux and macOS, but left scars on the
supported face, and plugin 0.1.0 could not take the calibration results. Upstream fixed that in
**0.7.759** after [gittrahan/support-fins#253](https://github.com/gittrahan/support-fins/issues/253): the
Config tab now accepts every engine option. The maintainer asked for two reports:

1. how the **calibrated settings** print;
2. **Full coverage** (`"mode": "full"`) on a part with **wide overhangs** (the newest code path).

## Plan, one variable at a time

| Step | What | Output |
|---|---|---|
| 0 | Install plugin 0.7.759 (`PLUGIN_FILE=plugins/support-fins/support_fins_orca-0.7.759.py scripts/install-support-fins.sh`); Orca's plugin list must show **0.7.759** | version + sha256 `0de0f02a…5c81` |
| 1 | Orca temperature tower for the PLA | best nozzle temperature |
| 2 | Orca Pressure Advance calibration → value into `printer.cfg`; *Enable pressure advance* off in every filament profile | PA value |
| 3 | Support Fins coupons, printed **without** the plugin (fins are in the files): `angle`, `gap`, `grip`, `pad` (guide: `docs/CALIBRATION.md` in support-fins) | `threshold`, `gap`, `tines`/`tineDensity`, `padStyle` |
| 4 | Re-slice the tilted `xyzCalibration_cube` (same `.3mf` as Chapters 1–2) with the calibrated config, e.g. `{"threshold": …, "gap": …, "tineDensity": …, "padStyle": "…"}` | compare the supported face with Chapters 1–2 |
| 5 | A part with **wide overhangs**, sliced with `"mode": "auto"` and then `"mode": "full"` | report for upstream |

Note the cube's 3 bare overhang regions at 45°: with a calibrated `threshold` (e.g. 44) or
`"mode": "full"` they should now get walls.

## Report back upstream

Post the results as a comment on [#253](https://github.com/gittrahan/support-fins/issues/253) (or a
*calibration result* issue for the coupons): printer, nozzle, filament, best rung of each coupon,
config used, and photos of the undersides.

## Log

### 2026-10-22: step 0, plugin 0.7.759 installed on Linux

- `PLUGIN_FILE=plugins/support-fins/support_fins_orca-0.7.759.py scripts/install-support-fins.sh`
- Installed in `/home/jglerner/.config/OrcaSlicer/orca_plugins/SupportFins/support_fins_orca.py`,
  **version 0.7.759**, sha256 `0de0f02ae34c1e46dd7f9456bae06385727b17473619fe0b52046f14ac8a5c81` ✅
  (matches the pinned copy).

### 2026-10-22 14:30: first print with 0.7.759, cube at 45°

- Fluidd: `xyzCalibration_cube_PLA_51m33s.gcode`, **280 layers** (×0.2 mm = 56 mm). Intended as the
  cube at 45°; the plugin log shows the actual pose (below).
  Slicer estimate 50 min 7 s. Nozzle 220 °C, bed 50 °C.
- First layer (Fluidd G-code preview): pad with brim and **3 fins with flared, tapered feet** (wider
  at the base), a different fin foot shape from 0.1.0's straight walls. First layers printing normally.

- Printer state at start: PA 0.04 / smooth time 0.04; acceleration 2000 mm/s², SCV 8 mm/s
  (first-layer limits).
- **Config used:** the old 0.1.0 config, saved with the process profile
  `0.20mm Standard @Creality K2 Pro 0.4 nozzle` and carried over unchanged:
  `{"apply_to": "no-supports", "bed_pad": true, "coverage": 0.5, "enabled": true, "tine_density": 0, "tines": true}`.
  In 0.7.759 these are accepted (`tine_density` and `bed_pad` are aliases) and equal the engine
  defaults, so this run is **case A: defaults (`mode` auto, `threshold` 45)**. Note: the Config is
  stored **per process profile**; *Restore defaults* would reset it to 0.7.759's
  `{"enabled": true, "apply_to": "no-supports"}`.
- **Plugin log (0.7.759 now writes `"version": "0.7.759"` in each entry):**

  | Field | Chapter 1–2 (0.1.0, ~26.4° pose) | This run (0.7.759) |
  |---|---|---|
  | `part_size_mm` | [40.0, 53.626, 53.626] | **[40.0, 56.282, 56.282]** |
  | `engine.overhangRegions` | 5 | 5 |
  | `engine.braces` (walls) | 4 | **5** |
  | `engine.tines` | 24 | 24 |
  | `engine.unserved` (too shallow, left bare) | 3 | **2** |
  | `engine.padTriangles` | 35,904 | 30,566 |
  | `engine.pins` | — | `false` (new field) |

- ⚠️ **The pose is not exactly 45°.** A 40 mm cube tilted exactly 45° about X has a 56.569 mm bounding
  box; 56.282 mm corresponds to **~39.2°** (or its complement ~50.8°). So one bottom face is below the
  45° threshold (gets fins) and the other above it. This run therefore does **not** reproduce the
  Chapter 1 "exactly 45° → 0 fins" case, and the extra wall cannot yet be credited to the new engine:
  the pose changed too. To be confirmed: the rotation shown in Orca's object panel.
- Pending: the rest of the log line (`result`, `layers_touched`), Orca Preview.
