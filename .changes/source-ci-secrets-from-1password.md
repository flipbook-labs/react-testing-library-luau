---
bump: patch
category: Changes
---

The tests job now sources `ROBLOX_API_KEY` from the shared Flipbook 1Password vault at run time via `load-secrets-action`, rather than from a repo-level GitHub Actions secret. No effect on the published package.
