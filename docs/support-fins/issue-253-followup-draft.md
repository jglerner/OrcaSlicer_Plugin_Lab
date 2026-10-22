# Draft: follow-up comment for gittrahan/support-fins#253

**Status: draft**, to be completed after the Full coverage test (23 Oct 2026) and posted by J. Lerner.
Sections marked `TODO` need the `mode full` results.

---

Thanks for 0.7.759, all three changes work as described. We tested it on Linux (Debian 13,
OrcaSlicer 2.5.0 nightly, Creality K2 Pro, 0.4 nozzle, PLA 220 °C, 0.2 mm layers) with the
`xyzCalibration_cube` (scaled to 40 mm, tilted about X).

### 1. Calibrated settings in Orca: the config reaches the engine

Same project, same pose, only the plugin config changed:

| Config | Plugin log | Engine CLI on the same mesh |
|---|---|---|
| defaults (`threshold` 45) | 5 walls, 24 tines; 2 too shallow | 5 walls, 24 tines |
| `threshold` 46 / 50 | 5 walls, 24 tines | 5 walls, 24 tines |
| `threshold` 52 | **7 walls, 32 tines** | **7 walls, 32 tines** |
| `mode` full | TODO | 13 walls, 59 tines |

The second bottom face sits at 50.82°, so 52 is the first threshold that reaches it; Orca and the
CLI agree on every row.

### 2. Print results

- **Defaults:** the new flared-foot walls fell off practically by hand, and the supported face came out
  flat with only a neat grid of small tine dots. Much better than our 0.1.0 print, which left wavy,
  drooping and torn patches. (Caveat: the pose also changed, so the 0.1.0 face was a steeper overhang.)
- **`threshold` 52:** one more wall under that face; removal just as easy and the finish
  indistinguishable from the defaults on this part.
- **Full coverage:** TODO (photos, removal, finish).

### 3. One thing we hit: a refused config can be invisible

With `"threshold": 99` the engine refuses the value (the plugin log has
`ValueError: threshold must be 30..70, got 99`), but on a part that rests on an edge the slice then
has no pad, and Orca only shows *"One object has an empty first layer and can't be printed"*. The
plugin's own message never reaches the user. Maybe the failure could also be surfaced as an Orca
warning/notification, or the pad kept even when the config is refused.

### FYI (not the plugin)

Orca's rotation panel showed *Absolute X = 45.00°* while the saved 3MF transform is a 39.18° rotation,
which cost us a while to understand why "45°" behaved like 39°. We'll report that to OrcaSlicer separately.

Thanks again!
