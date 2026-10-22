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

Note the cube's bare overhang regions at 45°: they need a `threshold` **above** 45 (e.g. 46; see the
log of 22 Oct: a *lower* threshold supports *less*) or
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

- **Pose (Orca rotation panel): X = 45.06° absolute**, Y = 0, Z = 0. Typing 45 did not stick exactly.
  - The bounding box (56.282 mm instead of 56.569 mm for a sharp 40 mm cube at 45°) is **not** a
    sign of a different angle: the cube's edges are bevelled, which shortens the diagonal. (An
    earlier estimate in this log of "~39°" from the bounding box was wrong for that reason; the
    Chapter 1–2 "~26°" estimate has the same caveat.)
  - At 45.06° the two bottom faces sit at **44.94°** and **45.06°** from horizontal. The 44.94° face is
    just past the default 45° threshold, so it **is** an overhang and gets fins. This run therefore
    does not prove the new engine changed the exact-45° behavior: the 0.06° offset alone explains it.
  - Orca's rotation field could not be set to 45.00°: the closest values were **44.96°/44.98°** and
    **45.06°** (it jumps over 45.00 with both typing and the step arrows). Both sides of 45 leave one
    bottom face just under 45° from horizontal, so both get fins.
- Pending: the rest of the log line (`result`, `layers_touched`), Orca Preview.

### 2026-10-22: exact 45° tested outside Orca (engine CLI)

Orca could not hold 45.00°, so the engine was run directly with the support-fins command-line
tool (same engine as the plugin), on a sharp 20 mm cube, at the angles Orca allowed and at
exactly 45°. Two builds: 0.7.771 (20 Oct, the first build after the 0.7.759 plugin release) and
0.7.814 (current `main`, 22 Oct). **Both gave identical results:**

| Rotation about X | defaults | `threshold` 44 | `threshold` 46 | `mode` full |
|---|---|---|---|---|
| 44.96° | 2 walls, 8 tines | **0** | 4 walls, 16 tines | 2 walls, 8 tines |
| **45.00°** | **0 walls** | 0 | **4 walls, 16 tines** | **0 walls** |
| 45.06° | 2 walls, 8 tines | **0** | 4 walls, 16 tines | 2 walls, 8 tines |

Findings:

1. **Exactly 45° still gets no fins with the defaults**, same as with 0.1.0: a face exactly on the
   threshold is not an overhang. The engine change did not alter that; the Orca run got fins only
   because Orca's rotation could not reach 45.00°.
2. **`threshold` is measured up from the plate and lower is stricter.** Faces *shallower* than the
   threshold get support, so **lowering it to 44 supports less** (0 walls here) and **raising it to 46
   supports the 45° faces** (4 walls). This is how `docs/CALIBRATION.md` defines it ("lower is
   harder"); the earlier suggestion in this chapter to use 44 was backwards and has been corrected.
3. **`"mode": "full"` does not help at exactly 45°.** Full coverage adds walls under overhangs that
   Auto leaves bare, but a face on the threshold is not an overhang in the first place, so there is
   nothing to cover.

Practical rule for this printer until `angle-coupon` is printed: for parts with 45° faces, use
`"threshold": 46` (or the calibrated value).

### 2026-10-22: exactly 45.00° reached in Orca, default config

- Rotation panel: **Absolute X = 45.00°**, Y = 0, Z = 0 (reached after several attempts). Object size
  40 × 56.277 × 56.277 mm, 344 triangles.
- Sliced (280 layers, 50 min 0 s model time, 22.45 g, 7.47 m). Preview: **no fins under the cube**;
  only the bottom edge on the bed with brim (`Brim` 1 min 11 s, 0.44 g). Orca shows its usual
  *"floating regions"* warning.
- This **matches the engine CLI prediction**: at exactly 45° the faces sit on the threshold and get no
  fins with the defaults. Pending: the plugin log line, to confirm `0 walls`.

### 2026-10-22 14:47–15:10: same result at 44.98°, 45.00° and with `threshold` 46

Plugin log, last three slices (time, `part_size_mm`, result):

| Time | Pose | Config | Result |
|---|---|---|---|
| 14:47:37 | 44.98° (56.2735 mm) | defaults | 5 walls, 24 tines; 2 overhangs too shallow |
| 14:53:16 | 45.00° (56.277 mm) | defaults | 5 walls, 24 tines; 2 overhangs too shallow |
| 15:07:17 | 45.00° (56.277 mm) | `"threshold": 46` (+ gyroid infill) | 5 walls, 24 tines; 2 overhangs too shallow |

- Orca stores the plugin Config **in the process preset** and re-sorts the keys alphabetically. After
  editing it shows *"Configuration updated. Save the preset to persist it."*
- The log (0.7.759) does **not** record the config the slice used, so a deliberate invalid value was
  used to check that edits reach the plugin: `"threshold": 99` (allowed range 30–70).
  - Result: the slice failed with **Orca's** *"One object has an empty first layer and can't be printed"*.
    That means the plugin ran, refused the config and added nothing (no pad), so the cube's edge alone
    left the first layer empty. **The edit does reach the plugin.**
  - Confirmed in the plugin log: `"error": "ValueError: threshold must be 30..70, got 99"`.
  - The plugin's own message about `threshold` was **masked** by Orca's empty-first-layer error. Worth
    reporting upstream: with a bad config on a part that relies on the pad, the user never sees why.
- Open question: why `threshold` 46 changes nothing on this cube when the engine CLI (sharp cube, no
  letters) goes from 0 to 4 walls. Hypotheses: (a) the 5 regions are mostly the recessed **X/Y/Z
  letters** (their ceilings are small overhangs), not the big faces; (b) Orca's "45.00°" is rounded
  for display, so the faces were already just past 45° and got walls at the default.

### 2026-10-22 15:14: Preview at layer 25 (5.00 mm), 45.00°, `threshold` 46

- Top/side view at layer 25: the cube's cross-section near its bottom edge, the pad with brim, and
  **3 parallel walls extending from one side only**, i.e. under **one** of the two big 45° faces.
  No walls under the other big face at this height.
- So hypothesis (a) (only letter recesses) is ruled out: one big face **is** supported. That face was
  already supported with the defaults (same counts), which fits hypothesis (b): Orca's "45.00°" leaves
  that face a hair past 45°.
- The second big face is not supported even with `threshold` 46, and the counts did not change
  (5 walls, 2 "too shallow"). Possibly that face is detected but reported as *too shallow for a fin
  this way up* (one of the 2 unserved). Next checks: `threshold` 50 and `"mode": "full"` at the same pose.

### 2026-10-22 15:17: `threshold` 50 changes nothing either

| Time | Pose | Config | Plugin log |
|---|---|---|---|
| 14:53:16 | 45.00° | defaults (threshold 45) | 5 walls, 24 tines; 2 too shallow |
| 15:10:58 | 45.00° | `threshold` 99 | `ValueError: threshold must be 30..70, got 99` |
| 15:14:25 | 45.00° | `threshold` 46 | 5 walls, 24 tines; 2 too shallow |
| 15:17:28 | 45.00° | `threshold` 50 | 5 walls, 24 tines; 2 too shallow |

- Every run is a fresh plugin execution (new log line), and the plugin code (`engine_options` →
  `host_options`) passes `threshold` to the engine unchanged. So the engine **receives** 46 and 50
  and still returns the same walls: on this cube (bevelled edges, recessed X/Y/Z letters) raising
  the threshold does not reach the second big face, unlike the sharp test cube in the CLI.
- Preview at layer 25 (top view) is identical in all three: 3 walls on one side of the bottom edge only.
- Next: run the exact part through the engine CLI (project `.3mf` to be added to `projects/`) to see
  which 5 regions the engine finds and why the 2 are "too shallow", then report upstream with the file.
