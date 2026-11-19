---
bump: patch
category: Internal
kind: tooling
---

Rename the dependency keys in `pkg.luau` to lowercase kebab-case, and have `lute run install` write an alias for each one, such as `@flipbook-batteries` and `@agent-skills`. `pkg.luau` also lists the files a Loom package ships, including a `modules/.config.luau` that keeps the `@instancetesting` alias with vendored copies.
