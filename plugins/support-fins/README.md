# Support Fins: exact copies of the tested plugin

| File | sha256 | Source | Used in |
|---|---|---|---|
| `support_fins_orca-65df17fa.py` | `65df17faabfbd870918b3f0fdc95e460229241afb996e2fb8ab830871706963f` | `plugins-latest` release of [gittrahan/support-fins](https://github.com/gittrahan/support-fins), downloaded on the morning of 13 Oct 2026 (after commit `a517023`) | Linux (Chapter 1) and macOS (Chapter 2) |

The `plugins-latest` release is rebuilt on every push to support-fins, and the plugin version
(`0.1.0`) does **not** change. By 17:41 the same day it already had a different sha256
(`d4e90d31…`): the Python glue code for Orca was identical, only the bundled JavaScript engine had
changed (the "Nozzle size" commits and the new layer-height cap). That is why the tested file is
kept here.

Install this copy:

```bash
PLUGIN_FILE=plugins/support-fins/support_fins_orca-65df17fa.py scripts/install-support-fins.sh
```

License: MIT, © 2026 gittrahan (see `LICENSE-support-fins`).
