## v0.2.1

### Changes

- Upgrade the Changewrite release action to `v0.7.0` and adopt its `publish-lock` check.

- Removed the e2e agent runbook (`.agents/skills/e2e`) and its documentation pointers. The library is for unit tests only and has no supported use outside a Jest context.

- Library source no longer carries per-file `--!strict` directives — strict typechecking is enforced repo-wide via `.luaurc`, and the spec files (previously `--!nonstrict`) are now strict-checked too.

- Test suites now use jest's `test` function instead of its `it` alias, matching the README examples.

### Dependencies

- Add AgentSkills `v0.4.0` as a dev dependency so agents can bootstrap the shared skills library.

- Upgrade FlipbookBatteries `v0.10.1` → `v0.12.0` and Lute `v1.0.1-nightly.20260508` → `v1.0.1-nightly.20260701`.


## [0.2.0] - 2026-07-03

### Fixes

- Fix the published package for Wally consumers: the artifact now has a root module (generated `dist/init.luau` re-exporting ReactTesting and its types), and requires are converted against a sourcemap that mirrors the consumer `_Index` layout, so `@pkg` dependencies resolve at the correct depth.

## [0.1.0] - 2026-07-03

### Features

- Initial release: an idiomatic-Luau testing library for react-lua components. `render`/`unmount`/`rerender` against real Instances, queries by text, placeholder, display value, and test-id tag (each in get/getAll/query/queryAll/find/findAll variants with prettyInstanceTree-annotated errors), `within` scoping, `waitFor` with React work flushing, and a `fireEvent` that works at user-level security — invoking React-registered handlers through react-roblox's test internals for pointer events and driving real engine signals for text and focus.
