---
bump: minor
category: Features
---

Initial release: an idiomatic-Luau testing library for react-lua components. `render`/`unmount`/`rerender` against real Instances, queries by text, placeholder, display value, and test-id tag (each in get/getAll/query/queryAll/find/findAll variants with prettyInstanceTree-annotated errors), `within` scoping, `waitFor` with React work flushing, and a `fireEvent` that works at user-level security — invoking React-registered handlers through react-roblox's test internals for pointer events and driving real engine signals for text and focus.
