# Chapter 1: Support Fins on Linux

> Read the [overview](00-Overview.md) first. Status: **completed on 13 Oct 2026: plugin approved on Linux** ✅.

## Test environment

| Item | Value |
|---|---|
| Distribution / version | Debian GNU/Linux 13 (trixie), kernel 6.12.111+deb13-amd64, x86_64 |
| Desktop session | Wayland, HiDPI (scale 2) |
| Stable OrcaSlicer installed | **2.3.0**, AppImage in `~/Applications/orca/` (no menu shortcut; 2.4.2 is not on this Linux machine) |
| Nightly tested | **2.5.0** (nightly of 13 Oct 2026), launched with `scripts/orca-nightly.sh` |
| Plugin version / sha256 | 0.1.0 / `65df17faabfbd870918b3f0fdc95e460229241afb996e2fb8ab830871706963f` (`plugins-latest` build after support-fins commit `a517023`, 13 Oct 2026) |
| Printer profile | Creality K2 Pro 0.4 nozzle |

## Step 0: prepare the working folder

```bash
mkdir -p ~/Projects/Orcaslicer/{apps,backups,downloads}
cd ~/Projects/Orcaslicer
git clone https://github.com/jglerner/OrcaSlicer_Plugin_Lab.git
```

## Step 1: download the nightly (alongside the stable release)

> **Do not uninstall the stable release.** An AppImage is a single file with no system install:
> stable and nightly live side by side, and the stable one stays the everyday printing version.
> What they share is the `~/.config/OrcaSlicer` folder, which is why step 2 backs it up.

1. Open <https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/nightly-builds>.
2. Download the **Linux AppImage** (if there is a choice of Ubuntu version, take the closest to your distro).
3. Make it executable:
   ```bash
   chmod +x ~/Applications/orca/OrcaSlicer*nightly*.AppImage
   ```
   If it complains about FUSE: `sudo apt install libfuse2t64` (Debian 13 / Ubuntu 24.04+) or `libfuse2` (Ubuntu 22.04).

**On this machine** AppImages live in `~/Applications/orca/`, the existing convention. The nightly
goes there too. Documents, backups and downloads live in `~/Projects/Orcaslicer/`.

> **Don't open the nightly yet.** Back up first (step 2).

## Step 2: backup + plugin install (one command)

With **every** Orca closed:

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
scripts/install-support-fins.sh
```

The script:
1. backs up `~/.config/OrcaSlicer` to `~/Projects/Orcaslicer/backups/OrcaSlicer-<date>.tar.gz`;
2. downloads `support_fins_orca.py` from the `plugins-latest` release into `~/Projects/Orcaslicer/downloads/` and records the version and SHA-256 in `SHA256SUMS.txt`;
3. copies the file into `~/.config/OrcaSlicer/orca_plugins/SupportFins/`.

Flatpak or another folder: `ORCA_DATA_DIR="/path/to/OrcaSlicer" scripts/install-support-fins.sh`.
To install the exact tested build instead of downloading:
`PLUGIN_FILE=plugins/support-fins/support_fins_orca-65df17fa.py scripts/install-support-fins.sh`.

**Manual alternative:** open the nightly and use **Plugins ▸ ▾ Browse plugins ▸ Install local plugin**,
pointing at the downloaded `.py`.

## Step 3: activate the plugin

1. Open the **nightly** with the launcher:
   ```bash
   ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab/scripts/orca-nightly.sh
   ```
   Opening the AppImage directly in a **Wayland** session shows no window: the terminal prints
   only `Gtk-WARNING ... gtk_window_set_titlebar()` and returns to the prompt. The launcher forces X11
   (`GDK_BACKEND=x11`), disables WebKit acceleration (`WEBKIT_DISABLE_DMABUF_RENDERER=1`,
   `WEBKIT_DISABLE_COMPOSITING_MODE=1`) and saves the output in `~/Projects/Orcaslicer/runs/`.
2. Main menu ▸ **Plugins**. "Support Fins" shows as *Inactive*.
3. Tick **Activate**. Expand the row and check that the *Support Fins* capability (slicing-pipeline type) is ticked too.
4. On first activation Orca's `uv` downloads `numpy` and `mini-racer`, which may take a while. On error, see the **Diagnostics** tab.

## Step 4: add the plugin to the process profile

**Activating the plugin alone does nothing.** The process profile has to reference it:

1. Process panel ▸ **Advanced** mode.
2. **Others ▸ Slicing Pipeline Plugin ▸ Add plugin ▸ Support Fins**.
3. **Save the profile.** Suggestion: duplicate the K2 Pro profile and save it as `K2 Pro – 0.20 – Fins`, leaving the normal profile untouched.

> A profile that references the plugin **will not slice** if the plugin is disabled or missing (Orca
> shows a "missing plugin" notice). This also applies when that profile is opened in a stable release.

## Step 5: first slice

1. A test part with a clear overhang. Suggestions: the project's own `angle-coupon.stl` ([download](https://github.com/gittrahan/support-fins/raw/main/web/calibration/angle-coupon.stl)), a tilted L-bracket, or a cube tilted **30° or 60°** (not 45°, see the log below).
2. On the part: **Enable support = OFF**.
3. **Brim type:** see the overview.
4. Slice. The plugin README says a few **"Plugin permission request"** prompts may appear (Python library reads, `socket.__new__`): answer **Yes**. *In our tests none appeared.*
5. Go to **Preview** and check that the fins are there.

## Step 6: record results

```bash
cd ~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab
scripts/collect-logs.sh "part, 0.20mm, PLA"
git add logs/linux && git commit -m "Linux: Support Fins test" && git push
```

To follow along live while slicing:

```bash
tail -f ~/.config/OrcaSlicer/log/python_*.log
```

### Checklist

| # | Check | Result | Note |
|---|---|---|---|
| 1 | Nightly opens and shows the **Plugins** menu | ✅ opens (2.5.0) | only with `scripts/orca-nightly.sh` (Wayland) |
| 2 | Plugin listed with version 0.1.0 | ✅ | Config tab shows the default JSON |
| 3 | Activation installs `numpy` + `mini-racer` without errors | ✅ | |
| 4 | "Slicing Pipeline Plugin" shows in the profile (Advanced ▸ Others) | ✅ | Support Fins added to `0.20mm Standard @Creality K2 Pro 0.4 nozzle` |
| 5 | Permission prompts appear and are accepted | ➖ none appeared | the plugin README expected some (`socket.__new__` etc.) |
| 6 | Fins visible in Preview | ✅ | tilted xyzCalibration_cube |
| 7 | `.jsonl` log reports fins/tines/layers | ✅ | `4 walls, 24 tines`, 141 layers, 0.76 s |
| 8 | Part with **Enable support ON** is skipped (`skipped ...`) | ➖ not tested | |
| 9 | Rotate the part + re-slice → fins follow | ➖ not tested | |
| 10 | G-code sent to the K2 Pro and printed | ✅ | 49 min 49 s, 7.39 m |
| 11 | First layer of the pad OK | ✅ | 5 mm brim; pad top surface rough |
| 12 | Fins break away cleanly | ⚠️ | come off by hand; leave scars on the supported face |
| 13 | Stable release still opens normally | ➖ not tested | stable here is 2.3.0 |

## Rolling back

```bash
# remove only the plugin
rm -rf ~/.config/OrcaSlicer/orca_plugins/SupportFins
# restore the whole configuration (with Orca closed)
mv ~/.config/OrcaSlicer ~/.config/OrcaSlicer.nightly-test
tar -xzf ~/Projects/Orcaslicer/backups/OrcaSlicer-<date>.tar.gz -C ~/.config
```

## Opening the nightly day to day (Linux)

Always through the launcher, which applies the Wayland fix and saves a log:

```bash
~/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab/scripts/orca-nightly.sh
```

For an icon in the application menu, create the shortcut once:

```bash
cat > ~/.local/share/applications/orcaslicer-nightly.desktop <<EOT
[Desktop Entry]
Type=Application
Name=OrcaSlicer Nightly (plugins)
Comment=OrcaSlicer 2.5 nightly with the Wayland fix
Exec=$HOME/Projects/Orcaslicer/OrcaSlicer_Plugin_Lab/scripts/orca-nightly.sh
Terminal=false
Categories=Graphics;3DGraphics;
EOT
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

The 2.3.0 release still opens from its own AppImage in `~/Applications/orca/`. Both share the same configuration folder.

## Log

### 2026-10-13: surveying the Linux machine

- Debian 13 (trixie).
- Only installed version: `~/Applications/orca/OrcaSlicer_Linux_AppImage_V2.3.0.AppImage`, **not 2.4.2**. No shortcut in `~/.local/share/applications`.
- `~/.config/OrcaSlicer`: 4.6 MB, last used 24 Aug. A `user_backup-v2.3.0/` already exists,
  created by Orca itself on a version upgrade. The nightly should create a similar one, but the
  script's backup is the one to restore from.
- Decision: leave 2.3.0 as it is and put the nightly next to it in `~/Applications/orca/`.

### 2026-10-13: choosing the nightly file

- File: `OrcaSlicer_Linux_AppImage_Ubuntu2404_nightly.AppImage` (x86_64, 204 MB).
  Published sha256: `b5f4b191b740a1e14cfb96748aa21b4cd68d96f32a577dd085a310fbf5d60b10`.
- Rejected: the `aarch64` (ARM) and `_belt` (belt printer) variants, the Flatpak (different
  configuration folder) and the `profile_validator` and `generate_system_cache` utilities.
- The file name is the same every day, so it is saved **with the date in the name**
  (`..._nightly-YYYYMMDD.AppImage`) to know which build was tested.

### 2026-10-13 09:50: download, backup and install

- Nightly: `~/Applications/orca/OrcaSlicer_Linux_AppImage_Ubuntu2404_nightly-20261013.AppImage`, sha256 **OK**.
- Backup: `~/Projects/Orcaslicer/backups/OrcaSlicer-20261013-095038.tar.gz`.
- Plugin installed in `~/.config/OrcaSlicer/orca_plugins/SupportFins/`, version 0.1.0, sha256 `65df17fa…963f`.
- **Note:** the plugin's sha256 changed compared with a test download a few hours earlier
  (`e4c283f6…6e66`), while the version stayed 0.1.0. The `plugins-latest` release is rebuilt on
  every support-fins push, and commit `a517023` ("Allow optional Sway depth…") landed at 07:38.
  The version number does not identify the build; **the sha256 does**. For macOS to give the same
  result it must use this very file (now kept in `plugins/support-fins/`).

### 2026-10-13: first launch of the nightly

- The "Bambu Cloud → Orca Cloud" migration notice appeared (profile sync since 2.4.0). Profiles on
  this machine were never synced through Bambu Cloud, so the notice was **ignored**.
- Decision: **no Orca Cloud login in the nightly.** A synced profile that references the plugin
  would reach other installs without the plugin, where Orca refuses to slice ("missing plugin").

### 2026-10-13 09:52–10:00: the nightly would not open (Wayland)

- Launching the AppImage directly showed no window, on both the 1st and 2nd attempt. The terminal only printed:
  ```
  Gtk-WARNING **: gtk_window_set_titlebar() called on a realized window
  Gdk-WARNING **: .../gdk/wayland/gdkcursor-wayland.c:251 cursor image size (45x45) not an integer multiple of scale (2)
  ```
- Fix: kill any leftover process (`pkill -f orca-slicer`) and launch with
  `GDK_BACKEND=x11 WEBKIT_DISABLE_DMABUF_RENDERER=1 WEBKIT_DISABLE_COMPOSITING_MODE=1`.
  **It opened, version 2.5.0.** Which of the three variables is actually required was not isolated.
- Created `scripts/orca-nightly.sh` so the variables don't have to be typed every time.

### 2026-10-13: the plugin in the Plugins window

- Support Fins listed, **version 0.1.0**, initially *Inactive*.
- The **Config** tab shows the plugin's default JSON (`apply_to: no-supports`, `bed_pad: true`,
  `coverage: 0.5`, `enabled: true`, `tine_density: 0`, `tines: true`), a sign that Orca loaded the
  file and read `get_default_config()`.
- Common confusion: fins do **not** appear under Support ▸ Type (only Normal and Tree). The right
  path is the **Plugins** menu plus **Others ▸ Slicing Pipeline Plugin** in the process profile.

### 2026-10-13: first findings (before reading the plugin log)

**1. Layers only went up to 0.14 mm.** The first hypothesis (0.2 nozzle printer) was
**ruled out**: the printer is already *Creality K2 Pro 0.4 nozzle*, with layer limits of 0.08 to
0.32 mm (Extruder tab screenshot). In the nightly's system profiles the default for that printer
is `0.20mm Standard @Creality K2 Pro 0.4 nozzle`. The following slice used 0.20 mm layers, so the
issue did not reappear. Not investigated further.

**2. Cube with 45° faces → "little contact area" + "first layer empty".**
Reproduced outside Orca with the same engine (support-fins CLI, 20 mm cube):

| Cube pose | Engine result |
|---|---|
| 0° (upright) | 0 fins, 0 tines (nothing to support) |
| **45° about X (resting on an edge)** | **0 fins, 0 tines**, `overhangRegions: 0`, pad only |
| 45° about X + 35.26° about Y (resting on a vertex) | 0 fins, 0 tines |
| 30° or 60° about X | **2 fins, 8 tines** |
| 45° about X with overhang threshold 50° | 4 fins, 16 tines |

- At 45° the bottom faces sit **exactly on the engine's 45° threshold**, so they are not treated
  as overhangs and get no fins. The engine still returns the pad, which the plugin should place on
  the first layer.
- "One object has an empty first layer and can't be printed" comes from **Orca itself**
  (`GCode.cpp`). It fires when the first layer has no extrusion, which is the case for a cube
  resting on an edge or vertex (line or point contact with the bed).
- Had the pad been added, the first layer would not be empty. So most likely **the plugin did not
  run on that slice**: it was not yet in *Others ▸ Slicing Pipeline Plugin*, or *Enable support*
  was on, or there was an error. `support_fins_log.jsonl` and `python_*.log` tell which.
- Better test part: a cube tilted **30° or 60°** about X, which is guaranteed to get fins.

### 2026-10-13 15:05: ✅ first slice with fins

Part: `xyzCalibration_cube.STL`, tilted (bounding box 40 × 53.6 × 53.6 mm). Profile
`0.20mm Standard @Creality K2 Pro 0.4 nozzle` with Support Fins in *Others ▸ Slicing Pipeline Plugin*,
Generic PLA. Sliced into **267 layers of 0.20 mm** (top at 53.40).

Plugin log (`support_fins_log.jsonl`), summarized:

| Field | Value | Meaning |
|---|---|---|
| `result` | `4 walls, 24 tines; 3 overhangs are too shallow for a fin this way up (tilt the part steeper)` | 4 fins with 24 tines; 3 regions on the 45° threshold left bare |
| `engine.overhangRegions` | 5 | |
| `engine.padTriangles` | 35,904 | the pad was generated |
| `layers_touched` | 141 | fins from z = 0.1 to 17.5 mm and from 24.3 to 34.7 mm |
| `frame_scale_vs_nominal` | [1.0, 0.99999999] | fins aligned with the part, no scale error |
| `elephant_foot` | [0.15, 1] | 0.15 mm compensation applied to the fins' first layer |
| `seconds` | 0.762 | plugin time per object |

Notes:
- Orca's warning *"It seems object … has floating regions. Please re-orient the object or enable
  support generation"* is **non-critical** and comes from Orca's own support checker
  (`PrintObject::generate_support_material`), which runs because supports are off. Expected with
  fins, and it matches the 3 regions the plugin reported as too shallow.
- **Brim:** the line-type list shows *Brim* (1 min 12 s, 0.44 g): the Auto brim around the fin pad.
- The earlier "empty first layer" error on the 45° cube most likely happened before the plugin
  was added to the profile. With the plugin active, the pad fills the first layer.

### 2026-10-13: first test print

- Part: the same tilted `xyzCalibration_cube`. Profile 0.20mm Standard, Generic PLA.
- Changes from the defaults: **6 % infill** (sparse infill density) and **5 mm brim** (Orca measures
  brim in mm; brim usage, 1 min 12 s and 0.44 g, was the same as the default Auto brim), to make
  sure it would not lift off the bed. Nothing else changed.
- To evaluate: pad adhesion on the first layer, fins intact to the top, whether the fins break
  away, and the finish of the supported faces.
- Preview at layer 40 (8.00 mm): **3 fins** rise from the pad up to the tilted face; the pad is
  surrounded by the brim. The 4th fin in the log is the 24.3–34.7 mm set, which starts on the part
  itself, not on the bed. Enable support off; sparse infill down to 4.26 g.
- Orca estimate: 49 min 19 s, 21.56 g (7.17 m). **Profile default speeds**, on purpose; speed up
  only in a later test, changing one variable at a time.
- 15:26: print started from Fluidd (`xyzCalibration_cube_PLA_49m19s.gcode`, 1.7 MB, 268 layers in
  Fluidd's count). Nozzle 220 °C, bed 50 °C, PA 0.038. (Before the first layer the nozzle goes to
  **240 °C only for the CFS purge**, `flush_max_temp: 240`, then back to 220 °C for the whole part.)
  Fluidd's G-code preview shows the 3 fins rising from the pad with the brim around them, so the
  G-code carries the geometry injected by the plugin.
- 15:32: 14 %, layer 22/268 (Z 4.42 mm), no issues. Nozzle 220 °C, bed 50 °C, chamber 32 °C,
  speed 129.7 mm/s, acceleration 12,000 mm/s² (from the profile). ETA 16:12.
- Layer 72 (14.4 mm), Fluidd G-code preview: the 3 fins are thin walls (one narrow loop each)
  **outside** the cube's cross-section, still climbing toward the tilted face, which they reach
  around 17.5 mm. The cube section shows walls, sparse infill, the letter recess and a strip of
  solid infill next to the fins.
- Layer 85 (17.0 mm), the critical point: in the G-code preview the 3 fins are just short tips
  touching the cube's edge (the tine phase). On camera the part is steady, the tilted face resting
  on the fins, and the pad with brim well seated. No lifting.
- 54 % (layer 120/268, Z 24.02 mm), 25 min 10 s elapsed. Remaining: 21 min 16 s per Fluidd vs
  24 min 8 s per slicer, so the printer was about **3 min ahead** of Orca's estimate (12,000 mm/s²
  acceleration, SCV 4 mm/s). The 4th fin (24.3–34.7 mm) starts here.
- Layer 185 (about 37 mm, above all fins), photo: the "X" face came out clean; the oval pad with
  brim still stuck to the bed; inside, the minimal infill with a few fine strings (normal at low
  infill). The fins are on the far side and not visible from this angle.
- 16:15: 99 %, layer 265/268, Z 53.01 mm. **Total time 49 min 49 s** vs 49 min 19 s estimated by
  Orca (only +30 s), and 7.39 m of filament vs 7.17 m estimated. The ~3 min lead seen mid-print did
  not hold: the end (top, small layers, minimum layer time) evened it out.
  **Orca's estimate is reliable for the K2 Pro.**
- **Finished part (photos, fins still attached):**
  - **3 thin parallel fins** hold the tilted face down to the bed, all intact, straight, with no
    failure or lifting. A wedge (triangular) structure joins the cube's bottom edge to the oval pad.
  - **X, Y and Z** faces clean, letters sharp. Regular layer lines on the Z face. One string inside the "X".
  - **Oval pad + brim:** adhered well and did not lift. The pad's top surface is rough, with small
    blobs and travel marks; irrelevant, since the pad is sacrificial.
  - Supported face (seen from below): flat and smooth, with a diagonal line at the wedge joint.
- **Removal:** everything came off **by hand**, no tools. Fins, wedges and oval pad came off
  together in one piece, plus a small square plate with "Y"-shaped tine marks.
- **Scars:** the face that rested on the fins is rough, with strings, pulled lines and torn patches
  where the tines and fin tips touched. The free faces (X, Y, Z) are fine.
- **J. Lerner's assessment:** lower the speed a bit and increase the layer time; the temperature
  (220 °C) seemed high for this part, so a temperature tower is worthwhile; and improve the contact
  between fins and part to reduce scarring. That was not the goal of this quick test.
- Result: **plugin approved on Linux** ✅. It installs, runs, injects the fins into the G-code, the
  print holds the overhang and the fins come off by hand. The supported face still needs calibration.

## Next tests (Linux), one variable at a time

1. Orca **temperature tower** (*Calibration ▸ Temperature*) for this PLA, 190–230 °C.
2. **Pressure Advance** calibration (*Calibration ▸ Pressure Advance*); the result goes into `printer.cfg` (see the overview).
3. **Support Fins' own calibration coupons** (`web/calibration/` in the support-fins repository;
   guide in `docs/CALIBRATION.md`). Print them **without** the plugin, since the fins are already in the file:
   - `angle-coupon.stl`: from what angle a face needs support (the "Overhang" setting);
   - `grip-coupon.3mf`: how many tines per fin. A ramp marked or torn at the tines means too much
     grip. Diagnosing this test's scars starts here;
   - `gap-coupon.3mf`: the gap between fin and part (default 0.2 mm, i.e. one layer);
   - `pad-coupon.3mf`: how easily the pad releases.
4. Repeat the `xyzCalibration_cube` with the calibrated values and compare the supported face.

> **Orca plugin limitation:** the Config tab only forwards `coverage`, `tines`, `tine_density` and
> `bed_pad` to the engine. **Overhang threshold, material (PLA/PETG), pad style and cutouts** exist in
> the engine (`plugins/shared/engine/options.json`) but the Orca plugin does not read them, and **the
> gap is fixed at 0.2 mm** in the engine (`web/prop/config.js`). Whatever the calibrations show for
> those parameters cannot be set in Orca today. Reported upstream: see
> [issue-orca-plugin-options.md](issue-orca-plugin-options.md).
