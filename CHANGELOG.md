## [0.2.0] - 2026-07-03

### Fixes

- Fix the published package for Wally consumers: the artifact now has a root module (generated `dist/init.luau` re-exporting ReactTesting and its types), and requires are converted against a sourcemap that mirrors the consumer `_Index` layout, so `@pkg` dependencies resolve at the correct depth.

## [0.1.0] - 2026-07-03

### Features

- Initial release: an idiomatic-Luau testing library for react-lua components. `render`/`unmount`/`rerender` against real Instances, queries by text, placeholder, display value, and test-id tag (each in get/getAll/query/queryAll/find/findAll variants with prettyInstanceTree-annotated errors), `within` scoping, `waitFor` with React work flushing, and a `fireEvent` that works at user-level security — invoking React-registered handlers through react-roblox's test internals for pointer events and driving real engine signals for text and focus.
