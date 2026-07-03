# Migrating from Roblox/react-testing-library-lua

This library is a redesign, not a drop-in replacement. The mental model
(render → query → fire → assert) carries over; the surface differs where the
verbatim port inherited DOM-isms or depended on infrastructure you don't have.

## The big one: fireEvent actually works outside Roblox

The Roblox port's `fireEvent` drives `VirtualInputManager`
(`SendMouseButtonEvent`, `SendKeyEvent`, ...). That service is
RobloxScriptSecurity — in an Open Cloud Luau execution session it isn't even
a valid service name, and plugins can't touch it either. The port's event
simulation only functions inside Roblox's internal test infrastructure.

Here, `fireEvent` invokes the handlers react-roblox registered (or triggers
the real signal where user Luau can), so it works in cloud test sessions,
Studio, and plugins. See [EVENT_DISPATCH.md](EVENT_DISPATCH.md).

## API deltas

| Roblox RTL | Here | Why |
| --- | --- | --- |
| `fireEvent(element, "click")` / `fireEvent.click(element)` | `fireEvent.activated(button)` | Roblox event names; no DOM aliases |
| `fireEvent.change(box, { target = { Text = "hi" } })` | `fireEvent.textChanged(box, "hi")` | explicit signature instead of a target-merge table |
| `fireEvent.focus` / `fireEvent.blur` | same names, `TextBox`-typed | real `CaptureFocus`/`ReleaseFocus` under the hood |
| `fireEvent.keyDown` / `keyUp` / `drag` / `tap` | not yet ported | were VirtualInputManager-only; file an issue with your use case |
| `screen.getByText(...)` | `result.getByText(...)` or `within(container)` | no global document exists; queries are container-scoped |
| `render(ui).debug()` | `print(prettyInstanceTree(result.container))` | one explicit tool |
| `cleanup()` auto-registered | `installCleanup(JestGlobals.afterEach)` | explicit opt-in, no import side effects |
| `waitFor(cb):expect()` (Promise) | `waitFor(cb)` (blocking, `task.wait` polling) | no Promise dependency |
| `findByText(...):expect()` | `result.findByText(...)` (blocking) | same |
| `getByText(container, "exact", { exact = false })` | same options: `{ exact = false }` | plus `pattern = true` for Lua patterns instead of RegExp |
| `getByRole` / `getByLabelText` / `getByTitle` / `getByAltText` | not provided | no accessibility tree in Roblox; the port didn't have them either |
| RegExp matchers (`RegExp("^foo")`) | `{ pattern = true }` with Lua patterns, or a function matcher | drops the LuauRegExp dependency |

## Test-id convention is compatible

Both libraries read CollectionService tags of the form `data-testid=<value>`,
and both honor a configurable attribute name via `configure`. Components
tagged for the Roblox port keep working.

## Typing

Everything is strict-mode Luau with no `any` casts in library source, so your
strict spec files get real inference: `getByText` returns `Instance` (narrow
with `:: TextButton` where you need class-specific APIs), option tables are
closed types, and misuse fails analysis instead of runtime.
