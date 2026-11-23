# Architecture

```
Admin UI  --POST /data.json-->  Host :8765 (server.py / PowerShell)
Floor TVs <--GET  /data.json--  data.json shared state
```

| Module | Role |
|--------|------|
| index.html | SPA dashboard (Chart.js, SheetJS, JSZip) |
| server.py | Threading HTTP + shared JSON API |
| Start-Dashboard.ps1 | PowerShell fallback host |
| Install.bat | LocalAppData install + Startup |

Shared payload includes executive KPIs and `_share` (achievements, orders, magazine).
