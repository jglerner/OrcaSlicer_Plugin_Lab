# Support Fins: cópias exatas do plugin testado

| Arquivo | sha256 | Origem | Usado em |
|---|---|---|---|
| `support_fins_orca-65df17fa.py` | `65df17faabfbd870918b3f0fdc95e460229241afb996e2fb8ab830871706963f` | release `plugins-latest` de [gittrahan/support-fins](https://github.com/gittrahan/support-fins), baixada em 13/10/2026 de manhã (depois do commit `a517023`) | Linux (Capítulo 1) e macOS (Capítulo 2) |

A release `plugins-latest` é refeita a cada push no support-fins, e a versão (`0.1.0`) **não** muda.
Às 17:41 do mesmo dia ela já tinha outro sha256 (`d4e90d31…`): o código Python de integração com
o Orca era idêntico, só o motor JavaScript embutido mudou (commits de "Nozzle size" e do limite
de altura de camada). Por isso o arquivo testado fica guardado aqui.

Instalar esta cópia:

```bash
PLUGIN_FILE=plugins/support-fins/support_fins_orca-65df17fa.py scripts/install-support-fins.sh
```

Licença: MIT, © 2026 gittrahan (ver `LICENSE-support-fins`).
