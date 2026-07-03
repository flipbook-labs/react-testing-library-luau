---
bump: patch
---

Library source no longer carries per-file `--!strict` directives — strict typechecking is enforced repo-wide via `.luaurc`, and the spec files (previously `--!nonstrict`) are now strict-checked too.
