# Contributing

1. Keep the dashboard a single `index.html` unless size forces a split.
2. New upload controls must call `publishShareExtras` or `pushSharedData`.
3. Use data URLs for media that other users must see (blob: is local-only).
4. Test: admin upload → second browser → Auto Sync shows the same KPIs.
