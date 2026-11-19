---
bump: patch
category: Internal
kind: tooling
---

Vendor the Lute dependencies into `.lpm/` with Lute `1.0.1-nightly.20261117` and require them through one `@lpm` alias, with FlipbookBatteries `v0.13.1`. `pkg.luau` also lists the files a Lute package ships, including a `modules/.config.luau` that keeps the `@instancetesting` alias with vendored copies.
