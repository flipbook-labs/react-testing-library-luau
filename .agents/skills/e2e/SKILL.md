---
name: e2e
description: Run the react-testing-library-luau test suite against a live DataModel. Use this to validate the library end-to-end — either headless through the rocale-cli cloud harness, or inside Roblox Studio via the command bar / Studio MCP. Use it whenever you want to confirm the full render → query → fireEvent → assert loop works from a fresh clone, or are asked to "run the e2e test".
---

# End-to-end test for react-testing-library-luau

The library's contract is: render a react-lua component against real
Instances, find things with queries, simulate events so handlers actually
run, and observe state changes. Two ways to prove it, in order of preference.

## Path A: headless cloud run (canonical, used by CI)

Prerequisites: [Rokit](https://github.com/rojo-rbx/rokit), and a `ROBLOX_API_KEY`
(Open Cloud key with Luau execution permission for the unit-testing universe)
in `.env` at the repo root or in the environment. Sibling flipbook-labs repos
carry a working `.env`.

```sh
rokit install      # pinned toolchain
lute run install   # loom + wally dependencies
lute run lint      # selene + stylua
lute run analyze   # strict typecheck of both packages + .lute scripts
lute run test      # builds dist/ and runs jest in a cloud DataModel
```

`lute run test` must end with all suites passing. The suite includes the
acceptance test (`ReactTesting/render.spec` → "acceptance: counter"): render
a `useState` counter, `fireEvent.activated` the Increment button, and watch
the rendered text change — the full loop this library exists for.

To run a subset: `lute run test -- --filter fireEvent`.

## Path B: inside Roblox Studio

Use this to verify behavior in a real interactive DataModel (focus handling
differs from headless — `fireEvent.blur`'s fallback exists for exactly that
gap).

1. Build the library: `lute run build --channel dev`. This produces
   `dist/InstanceTesting` and `dist/ReactTesting` with Roblox-style requires.
2. Get the packages into a place. The simplest route is the tests project:
   `rojo build tests.project.json -o e2e.rbxl`, then open `e2e.rbxl` in
   Studio (it contains `ReplicatedStorage.Packages` with React, ReactRoblox,
   and both library packages).
3. Run Luau inside Studio — via the Studio MCP run-code tool if connected
   (see agent-gateway's `use-agent-gateway` skill for setup), or paste into
   the Command Bar (View → Command Bar):

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local ReactTesting = require(Packages.ReactTesting)

local function Counter()
	local count, setCount = React.useState(0)
	return React.createElement("TextButton", {
		Text = "Count: " .. count,
		[React.Event.Activated] = function()
			setCount(count + 1)
		end,
	})
end

local result = ReactTesting.render(React.createElement(Counter))
assert(result.getByText("Count: 0"), "initial render failed")

ReactTesting.fireEvent.activated(result.getByText("Count: 0"))
assert(result.getByText("Count: 1"), "click did not update state")

result.unmount()
print("[e2e] react-testing-library-luau round trip OK")
```

You should see `[e2e] react-testing-library-luau round trip OK` in the
Output window. Note: in Studio (no mock scheduler), `render` and `fireEvent`
still work because `ReactRoblox.act` falls back to a hard error **only when
handlers schedule work the real scheduler hasn't flushed synchronously** — if
the assert on "Count: 1" fails here but the cloud suite passes, wrap the
assertion in `ReactTesting.waitFor`.

### Things worth verifying in Studio

- The counter round trip above.
- Focus fidelity: render a `TextBox` with `Focused`/`FocusLost` handlers,
  `fireEvent.focus` then `fireEvent.blur`, and confirm each handler ran
  exactly once (the blur fallback must not double-fire where the engine
  delivers the real FocusLost).
- Query errors: `result.getByText("nope")` should error with an indented
  Instance tree of the container.
