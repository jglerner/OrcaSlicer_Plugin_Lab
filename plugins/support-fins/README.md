# Support Fins: exact copies of the tested plugin

| File | sha256 | Source | Used in |
|---|---|---|---|
| `support_fins_orca-65df17fa.py` | `65df17faabfbd870918b3f0fdc95e460229241afb996e2fb8ab830871706963f` | `plugins-latest` release of [gittrahan/support-fins](https://github.com/gittrahan/support-fins), downloaded on the morning of 13 Oct 2026 (after commit `a517023`) | Linux (Chapter 1) and macOS (Chapter 2) |
| `support_fins_orca-0.7.759.py` | `0de0f02ae34c1e46dd7f9456bae06385727b17473619fe0b52046f14ac8a5c81` | `plugins-latest`, downloaded 19 Oct 2026: **Orca plugin 0.7.759**, the first build with all engine options in the config and real version numbers (after [gittrahan/support-fins#253](https://github.com/gittrahan/support-fins/issues/253)) | Chapter 3 (planned) |

The `plugins-latest` release is rebuilt on every push to support-fins, and the plugin version
(`0.1.0`) does **not** change. By 17:41 the same day it already had a different sha256
(`d4e90d31…`): the Python glue code for Orca was identical, only the bundled JavaScript engine had
changed (the "Nozzle size" commits and the new layer-height cap). That is why the tested file is
kept here. From 0.7.x on, the version number changes with every build that changes the plugin
(upstream #341), so builds can be told apart without sha256, but pinned copies are still kept here.

Install a pinned copy (Orca closed):

```bash
# build tested in Chapters 1 and 2
PLUGIN_FILE=plugins/support-fins/support_fins_orca-65df17fa.py scripts/install-support-fins.sh
# 0.7.759, all engine options in the Config tab (Chapter 3)
PLUGIN_FILE=plugins/support-fins/support_fins_orca-0.7.759.py scripts/install-support-fins.sh
```

License: MIT, © 2026 gittrahan (see `LICENSE-support-fins`).
