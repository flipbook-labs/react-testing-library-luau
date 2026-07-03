# react-testing-library-luau

> Idiomatic-Luau testing library for [react-lua](https://github.com/jsdotlua/react-lua)
> components, running against real Instances in a live DataModel.

```luau
local React = require(Packages.React)
local ReactTesting = require(Packages.ReactTesting)

ReactTesting.installCleanup(JestGlobals.afterEach)

test("clicking increments", function()
	local function Counter()
		local count, setCount = React.useState(0)
		return React.createElement("TextButton", {
			Text = `Count: {count}`,
			[React.Event.Activated] = function()
				setCount(count + 1)
			end,
		})
	end

	local result = ReactTesting.render(React.createElement(Counter))

	ReactTesting.fireEvent.activated(result.getByText("Count: 0") :: TextButton)

	expect(result.getByText("Count: 1")).toBeDefined()
end)
```

Full reference: [docs/API.md](docs/API.md). Coming from Roblox's port?
[docs/migration-from-roblox-rtl.md](docs/migration-from-roblox-rtl.md).

## Why not the existing port?

Roblox's [react-testing-library-lua](https://github.com/Roblox/react-testing-library-lua)
is a verbatim transpilation of the JS library — and its `fireEvent` drives
`VirtualInputManager`, a RobloxScriptSecurity service that only exists in
Roblox's internal test infrastructure. Outside it (plugins, Studio command
bar, Open Cloud Luau execution), the port cannot simulate events at all.

This library keeps the Testing Library mental model but is designed for Luau
and for user-level security:

- **Event dispatch that works everywhere**: React handler invocation through
  react-roblox's exported test internals, plus real engine signals where Luau
  can trigger them ([docs/EVENT_DISPATCH.md](docs/EVENT_DISPATCH.md))
- **Strict-mode Luau throughout (via `.luaurc`); no `any` casts** in library source (CI-enforced);
  explicit option types instead of merge-based option objects
- **Roblox event names** (`activated`, `textChanged`, `focus`), not DOM
  aliases (`click`, `change`)
- **No global `screen`** — queries come from `render()` results and
  `within(container)`; Roblox has no global document
- **No LuauPolyfill / Promise dependencies** — `waitFor` and `findBy*` are
  plain blocking calls polling with `task.wait`

## Queries

`ByText`, `ByPlaceholderText`, `ByDisplayValue`, and `ByTestId`
(CollectionService `data-testid=<value>` tags, compatible with the Roblox
port's convention) — each as `get / getAll / query / queryAll / find /
findAll`. `ByRole`/`ByLabelText`/`ByTitle`/`ByAltText` are intentionally
absent: Roblox has no accessibility tree.

## Workspace

Two packages, published together as one Wally artifact:

- [`modules/instance-testing`](modules/instance-testing) — queries over plain
  Instances (the folded dom-testing-library layer; no React dependency —
  usable with Roact/Fusion/hand-built UI too)
- [`modules/react-testing`](modules/react-testing) — render / fireEvent /
  act / waitFor, re-exporting the queries

The cross-package wiring is `.luaurc` aliases plus the rojo sourcemap that
darklua converts requires against — Loom (`loom.config.luau` at the root) is
only for Lute-side tooling dependencies, since this library runs in a
DataModel, not under Lute.

## Development

```sh
rokit install      # toolchain (lute, rojo, darklua, selene, stylua, wally, ...)
lute run install   # loom + wally dependencies
lute run lint      # selene + stylua
lute run analyze   # strict typecheck (luau-lsp, new solver)
lute run test      # jest via rocale-cli cloud execution (needs ROBLOX_API_KEY in .env)
```

The e2e runbook (headless and in-Studio) lives in
[.agents/skills/e2e/SKILL.md](.agents/skills/e2e/SKILL.md).

## License

MIT. Portions of test suites and query behavior derive from Roblox's
MIT-licensed testing-library ports — see [LICENSE](LICENSE).
