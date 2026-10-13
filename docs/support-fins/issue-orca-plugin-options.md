# Upstream issue for gittrahan/support-fins

**Status: posted** by J. Lerner on 13 Oct 2026 as [gittrahan/support-fins#24](https://github.com/gittrahan/support-fins/issues/24)
(no existing issue covered it). The text below is what was posted.

---

**Title:** Orca plugin: expose more engine options in the plugin config (threshold, material, pad style, cutout, gap)

**Body:**

First of all, thanks for the Orca plugin: slicing-time fins are a great idea, and it worked out of the box.

### What we tested

- OrcaSlicer **2.5.0 nightly** (13 Oct 2026) on **Debian 13 (x86_64)** and **macOS 27.0.1 (Apple Silicon)**
- Printer: Creality K2 Pro (Klipper), 0.4 nozzle, 0.20 mm layers, PLA at 220 °C
- Plugin `support_fins_orca.py` 0.1.0 from `plugins-latest`, **sha256 `65df17fa…963f`**, the same file on both machines
- Part: `xyzCalibration_cube` (40 mm), tilted ~26° about X, the same `.3mf` on both machines

### Results

- The plugin installed, activated (`uv` pulled `numpy` + `mini-racer`, including arm64 on the Mac) and ran on both systems.
- `support_fins_log.jsonl` was **identical on Linux and macOS**: `4 walls, 24 tines; 3 overhangs are too shallow…`, and the same fin area on all 141 layers. Only `frame_scale` differed, by about 1e-9.
- Both prints succeeded. The fins and pad came off by hand in one piece.
- The supported face shows scarring: wavy, drooping layers between the walls and a row of small dots where the tines touched. We'd like to tune that with your calibration coupons (`grip`, `gap`, `angle`). That's where the plugin limits us.

### The limitation

`support_fins_orca.py` only reads `enabled`, `apply_to`, `coverage`, `tines`, `tine_density` and `bed_pad` from the plugin config (`_DEFAULTS` / `_cfg()`), and `compute_fins()` forwards only those to the engine. `plugins/shared/engine/options.json` defines more options that Orca users can't reach:

| Option | Why we'd want it in Orca |
|---|---|
| `threshold` (Overhang °) | Result of `angle-coupon`. Our 45° faces sit exactly on the default threshold, so the engine reports them as too shallow and leaves them bare |
| `material` (PLA/PETG) | PETG users |
| `padStyle` | Result of `pad-coupon` (off / light / sure) |
| `cutout` | Saves plastic on tall walls |
| `plateOnly`, `sway.*` | Feature parity with the site |
| **Support gap / Pad gap** | Result of `gap-coupon` / `pad-coupon`. `docs/CALIBRATION.md` sends users to *Clearances ▸ Support gap*, but as far as we can tell the gap isn't in `options.json` yet (`web/prop/config.js` has `gap: 0.2`), so this one may need engine support first |

### Suggestion

The shared entry already has `optionsFromDialog()` (`fins_entry.js`), which validates any `options.json` key. The Orca plugin could accept **any `options.json` key** in its JSON config and pass it through `optionsFromDialog`, instead of keeping its own short list. The calibration results would then map 1:1 onto the Orca config tab. Keeping `bed_pad` / `tine_density` as aliases would preserve existing configs.

### Smaller notes (FYI, not bugs in the plugin)

- No *Plugin permission request* prompts appeared on either system, although the README says a few will. Maybe the V8 context now starts while the audit hook is still off (see the comment in `_engine_ctx()`).
- `plugins-latest` was rebuilt the same day (sha256 changed to `d4e90d31…`) while the plugin `version` stayed `0.1.0`. Bumping the version, or showing the engine commit in the plugin description, would make it easier to tell builds apart.

Thanks again! Happy to test a build.
