# MISO Ribbon — Executive Packing Command Center

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Deploy](https://img.shields.io/badge/deploy-localhost%3A8765-green.svg)](docs/DEPLOYMENT.md)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](docs/DEPLOYMENT.md)

**Analytics-grade live dashboard** for packing floor operations at **MISO Ribbon PVT LTD**.

One admin uploads the monthly Excel report. Every TV and browser on the floor stays in sync.

## Quick start

```bat
Install.bat
```

Opens **http://127.0.0.1:8765/**

| Role | Action |
|------|--------|
| Admin | Upload Report → toast **LIVE SHARED** |
| Other users | Open `http://HOST-IP:8765/` · Auto Sync ON |

## Stack

- Single-page UI (Chart.js, SheetJS, JSZip)
- Python `ThreadingHTTPServer` or PowerShell `HttpListener`
- Shared state: `data.json` (+ `_share` extras)

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Deployment](docs/DEPLOYMENT.md)
- [Features](docs/FEATURES.md)
- [Changelog](docs/CHANGELOG.md)
- [Release v1.0.0](docs/RELEASE.md)

## License

MIT © 2026 MISO Ribbon PVT LTD / [misotechindia](https://github.com/misotechindia)
