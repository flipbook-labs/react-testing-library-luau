# API reference

Everything below is exported from the `ReactTesting` package
(`modules/react-testing`). The query functions are re-exports from
`InstanceTesting` (`modules/instance-testing`), which can also be used on its
own against non-React Instance trees.

All functions are fully typed under `--!strict`. Types referenced here:

```luau
type TextMatch = string | (text: string, instance: Instance) -> boolean

type TextMatchOptions = {
	exact: boolean?,      -- default true: normalized text must equal the matcher
	                      -- false: case-insensitive substring match
	pattern: boolean?,    -- default false: treat a string matcher as a Lua pattern
	normalizer: ((text: string) -> string)?,  -- replaces trim+collapse default
}

type WaitForOptions = {
	timeout: number?,     -- seconds, default 1
	interval: number?,    -- seconds, default 0.05
}
```

## render

```luau
render(element: React.Node, options: RenderOptions?): RenderResult
```

Mounts `element` with `ReactRoblox.createRoot` inside `ReactRoblox.act`.

- `options.container: Instance?` — render into this instance. You own its
  lifetime. Without it, render creates a `ScreenGui` named
  `ReactTestingContainer`, parents it to `CoreGui` (works in both cloud test
  sessions and Studio), and destroys it on unmount/cleanup.

`RenderResult` fields:

- `container: Instance`
- `unmount: () -> ()` — unmounts and (for the default container) destroys it
- `rerender: (element: React.Node) -> ()` — renders a new element into the same root
- every bound query, sync and async (see Queries below), scoped to the container

```luau
local result = render(React.createElement(Counter))
result.getByText("Count: 0")
result.rerender(React.createElement(Counter, { step = 2 }))
result.unmount()
```

## cleanup / installCleanup

```luau
cleanup: () -> ()
installCleanup: (afterEach: (callback: () -> ()) -> ()) -> ()
```

`cleanup()` unmounts every root `render` created and destroys containers it
owns — including renders from tests that failed before reaching `unmount`.
The one-liner for spec files:

```luau
ReactTesting.installCleanup(JestGlobals.afterEach)
```

## fireEvent

Roblox event names, not DOM names. Every helper wraps its work in
`ReactRoblox.act`. Mechanisms are documented in
[EVENT_DISPATCH.md](EVENT_DISPATCH.md).

| Helper | Signature | Mechanism |
| --- | --- | --- |
| `fireEvent.activated` | `(instance: GuiButton) -> ()` | handler invocation |
| `fireEvent.mouseButton1Click` | `(instance: GuiButton) -> ()` | handler invocation |
| `fireEvent.mouseButton2Click` | `(instance: GuiButton) -> ()` | handler invocation |
| `fireEvent.mouseEnter` | `(instance: GuiObject) -> ()` | handler invocation (passes element center as x, y) |
| `fireEvent.mouseLeave` | `(instance: GuiObject) -> ()` | handler invocation |
| `fireEvent.textChanged` | `(instance: TextBox, text: string) -> ()` | real engine signal (sets `.Text`) |
| `fireEvent.focus` | `(instance: TextBox) -> ()` | real engine signal (`CaptureFocus`) |
| `fireEvent.blur` | `(instance: TextBox) -> ()` | `ReleaseFocus`, with direct invocation fallback so the handler runs exactly once even in headless DataModels |
| `fireEvent.custom` | `(instance: Instance, eventKey: unknown, ...unknown) -> boolean` | escape hatch for any `React.Event.*` / `React.Change.*` key; returns whether a handler was registered |

```luau
fireEvent.activated(result.getByText("Submit") :: TextButton)
fireEvent.textChanged(result.getByPlaceholderText("Username") :: TextBox, "marin")
fireEvent.custom(frame, React.Event.TouchTap)
```

## Queries

Four query subjects, each in six variants. Container-first forms take the
container as the first argument; `render()` results and `within(container)`
provide bound forms without it.

| Subject | Matches | Matcher type |
| --- | --- | --- |
| `*ByText` | `TextLabel`/`TextButton` `.Text` | `TextMatch` |
| `*ByPlaceholderText` | `TextBox.PlaceholderText` | `TextMatch` |
| `*ByDisplayValue` | `TextBox.Text` | `TextMatch` |
| `*ByTestId` | CollectionService tag `data-testid=<value>` | `string` (exact) |

| Variant | Returns | Not found | Multiple found |
| --- | --- | --- | --- |
| `getBy*` | `Instance` | error | error |
| `getAllBy*` | `{ Instance }` | error | ok |
| `queryBy*` | `Instance?` | nil | error |
| `queryAllBy*` | `{ Instance }` | `{}` | ok |
| `findBy*` | `Instance` | polls, then error | error |
| `findAllBy*` | `{ Instance }` | polls, then error | ok |

Text queries accept `TextMatchOptions`; `findBy*` additionally accept
`WaitForOptions` as the last argument. Query errors embed a
`prettyInstanceTree` rendering of the container.

Tag components for `*ByTestId` with react-lua's Tag prop:

```luau
React.createElement("Frame", {
	[ReactRoblox.Tag] = "data-testid=sidebar",
})
-- later:
result.getByTestId("sidebar")
```

Intentionally not ported: `ByRole`, `ByLabelText`, `ByTitle`, `ByAltText` —
Roblox has no accessibility tree to query.

## within

```luau
within(container: Instance): BoundQueries
```

Binds the sixteen synchronous queries to a container. Use it to scope
assertions to a subtree:

```luau
local form = result.getByTestId("login-form")
within(form).getByText("Submit")
```

## waitFor

```luau
waitFor(callback: () -> (), options: WaitForOptions?) -> ()
```

Polls `callback` until it stops throwing or `timeout` elapses, then rethrows
the last error. Each attempt first flushes pending React work, so state
updates made outside `act` (timers, signal handlers) become visible between
polls.

## act

```luau
act(callback: () -> ()) -> ()
```

Re-export of `ReactRoblox.act`. The test runner must set
`_G.__ROACT_17_MOCK_SCHEDULER__ = true` before Jest loads (the repo's
`.lute/tasks/run-tests.luau` does).

## prettyInstanceTree

```luau
prettyInstanceTree(root: Instance, options: { maxDepth: number?, highlight: Instance? }?): string
```

The tree renderer query errors use, exported for debugging. Shows class,
name, displayed text, placeholder, and test-id tags; `highlight` marks one
instance with `◄`.

## configure

```luau
configure({ testIdAttribute: string? })
```

Changes the tag prefix `*ByTestId` looks for (default `data-testid`).
