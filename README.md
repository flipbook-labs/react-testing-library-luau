# ReactTestingLibraryLuau

ReactTestingLibraryLuau renders react-lua components into real Instances in a live DataModel, then queries them and fires events the way Testing Library does. It runs inside Jest specs on Roblox and uses Roblox event names such as `activated` and `textChanged`. The full API is in [docs/API.md](docs/API.md).

## Install

Add this to `wally.toml`:

```toml
[dev-dependencies]
ReactTestingLibraryLuau = "flipbook-labs/react-testing-library-luau@0.2.0"
```

## Use

Render a component, click a button, and assert on the result:

```luau
local JestGlobals = require(Packages.JestGlobals)
local React = require(Packages.React)
local ReactTesting = require(Packages.ReactTestingLibraryLuau)

local expect = JestGlobals.expect
local test = JestGlobals.test

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

Text fields take `fireEvent.textChanged`, which sets the TextBox's `Text` and runs its change handler:

```luau
ReactTesting.fireEvent.textChanged(result.getByPlaceholderText("Username") :: TextBox, "marin")
```

## Queries

Queries match `Text`, `PlaceholderText`, a TextBox's `Text`, and `data-testid` tags. Each one comes in `get`, `getAll`, `query`, `queryAll`, `find`, and `findAll` forms as top-level functions that take the container first. `render()` results bind every form to the rendered tree, and `within(container)` binds only the `get` and `query` forms. `ByRole`, `ByLabelText`, `ByTitle`, and `ByAltText` do not exist, because Roblox has no accessibility tree.

## Differences from Roblox's port

Roblox's [react-testing-library-lua](https://github.com/Roblox/react-testing-library-lua) sends `fireEvent` through `VirtualInputManager`, a service limited to Roblox's internal test infrastructure. Outside that infrastructure, such as in a plugin or the Studio command bar, the port cannot simulate events. This library calls React handlers directly and uses real engine signals where Luau can trigger them, so events also fire outside that infrastructure. [docs/EVENT_DISPATCH.md](docs/EVENT_DISPATCH.md) explains each event's mechanism. To move existing tests, see [docs/migration-from-roblox-rtl.md](docs/migration-from-roblox-rtl.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.

Portions of the test suites and query behavior are derived from Roblox/dom-testing-library-lua and Roblox/react-testing-library-lua, Copyright (c) Roblox Corporation, used under the MIT License. See [LICENSE](LICENSE).
