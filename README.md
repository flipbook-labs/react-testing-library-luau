# react-testing-library-luau

> Idiomatic-Luau testing library for [react-lua](https://github.com/jsdotlua/react-lua)
> components, running against real Instances in a live DataModel.

**Status: pre-release scaffolding.** The event-dispatch mechanism is validated
(see [docs/EVENT_DISPATCH.md](docs/EVENT_DISPATCH.md)); the query and render
APIs are under construction. See [PLAN.md](PLAN.md) for the roadmap.

## Why not the existing port?

Roblox's [react-testing-library-lua](https://github.com/Roblox/react-testing-library-lua)
is a verbatim transpilation of the JS library. It leans on LuauPolyfill, loses
type information through object merges, and — critically — its `fireEvent`
drives `VirtualInputManager`, which is RobloxScriptSecurity and only works in
Roblox's internal test infrastructure.

This library keeps the Testing Library mental model (render, queries,
fireEvent, waitFor) but is designed for Luau:

- `--!strict` throughout; no `any` casts in library source (CI-enforced)
- Explicit option types instead of merge-based option objects
- Roblox event names (`Activated`, `FocusLost`), not DOM names (`click`, `blur`)
- Event dispatch that works at user-level security: React handler invocation
  via react-roblox's exported internals, plus real engine signals where Luau
  can trigger them

## Workspace

Two Loom packages wired with a path dependency:

- [`modules/instance-testing`](modules/instance-testing) — queries over plain
  Instances (the folded dom-testing-library layer; no React dependency)
- [`modules/react-testing`](modules/react-testing) — render / fireEvent / act /
  waitFor for react-lua components

## Development

```sh
rokit install      # toolchain (lute, rojo, darklua, selene, stylua, wally, ...)
lute run install   # loom + wally dependencies
lute run lint      # selene + stylua
lute run test      # jest via rocale-cli (needs ROBLOX_API_KEY in .env)
```

## License

MIT. Portions of test suites and query behavior derive from Roblox's
MIT-licensed testing-library ports — see [LICENSE](LICENSE).
