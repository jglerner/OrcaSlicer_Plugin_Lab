"""Compare the Support Fins logs from Linux and macOS, field by field.
Usage: python3 -I compare.py support_fins_log-linux.json support_fins_log-macos.json"""
import json
import sys

a, b = (json.load(open(p)) for p in sys.argv[1:3])
for k in a:
    if a[k] != b[k] and k != "layers":
        print(f"DIFFERENT {k}: {a[k]}  |  {b[k]}")
print("layers equal:", a["layers"] == b["layers"], len(a["layers"]), len(b["layers"]))
