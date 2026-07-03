# Event dispatch mechanism

How `fireEvent` reaches the handlers a component registered, given that Roblox
offers no way to synthesize real user input from user-level Luau. Validated by
the Phase 0 spike (`modules/react-testing/src/__spikes__/eventDispatch.spec.luau`)
against a live DataModel via rocale-cli (Open Cloud Luau execution) on 2026-07-02.
All six spike tests passed.

## Why not engine-level input

- `VirtualInputManager` is RobloxScriptSecurity. In an Open Cloud Luau
  execution session it is not even a valid service name
  (`GetService` throws). Roblox's own `dom-testing-library-lua` uses it
  (`SendMouseButtonEvent` etc.) — that port only works in Roblox's internal
  test infrastructure, which runs with elevated permissions. Not an option for
  plugins, the command bar, or cloud sessions.
- `RBXScriptSignal`s cannot be fired from user Luau, so `button.Activated`
  cannot be raised directly.

## Mechanism A — listener invocation (pointer-style events)

For events with no user-Luau trigger (`Activated`, `MouseButton1Click`,
`MouseEnter`, ...), we look up the handler prop React registered and call it
directly:

```luau
local internals = ReactRoblox.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED
local props = internals.Events.getFiberCurrentPropsFromNode(instance)
local handler = props[React.Event.Activated]
ReactRoblox.act(function()
    handler(instance, ...)
end)
```

Why this is sound:

- `getFiberCurrentPropsFromNode` is exported by react-roblox through the same
  internals object upstream React DOM exposes for testing tools (RTL-js relies
  on the equivalent). Source: `react-roblox/src/client/ReactRoblox.luau`
  (`Internals.Events`), backed by the `instanceToProps` map in
  `ReactRobloxComponentTree.luau`, updated on every commit — the spike verified
  a rerender swaps the handler (no stale props).
- `React.Event.Foo` / `React.Change.Foo` are the exact table keys host props
  are stored under, and both are public exports.
- Handlers receive `(instance, ...eventArgs)` — the same convention
  `SingleEventManager` uses when a real signal fires
  (`react-roblox/src/client/roblox/SingleEventManager.luau`).
- Wrapping the call in `ReactRoblox.act` batches the resulting state updates,
  matching how RTL-js wraps fireEvent in act via its `eventWrapper` config.

Limitation: this invokes the React handler only. Engine-side behavior of a
real click (selection visuals, sounds, other non-React `:Connect` listeners on
the same instance) does not happen. That is acceptable for a testing library
whose contract is "your component's handlers run".

## Mechanism B — real engine triggers (property/focus events)

Where user Luau *can* cause the real signal, we do, for maximum fidelity —
react-roblox connects handler props to the actual signals
(`SingleEventManager:connectEvent` / `connectPropertyChange`), so the real
signal runs the real handler:

| fireEvent helper | Trigger | Spike result |
| --- | --- | --- |
| `textChanged(box, text)` | set `TextBox.Text` (fires `GetPropertyChangedSignal("Text")`) | ✅ handler observed the new text |
| `focus(box)` | `TextBox:CaptureFocus()` | ✅ `Focused` handler fired, even headless in the cloud session |
| `blur(box)` | `TextBox:ReleaseFocus()` | ⚠️ `FocusLost` did **not** fire in the cloud session — investigate in Phase 3 (may need a deferred frame, or `ReleaseFocus` semantics differ headless). Fallback: invoke the `FocusLost` handler via mechanism A. |

The `change`-style event in Roblox's DTL port does the same thing (sets
properties directly), so this matches prior art.

## Environment probes (cloud session, place 123506190725771)

- `game:GetService("VirtualInputManager")` → error: not a valid service name.
- `ScreenGui.Parent = CoreGui` → permitted.
- `CaptureFocus` → permitted and functional.

## Consequences for the library

- `fireEvent` = typed helpers choosing mechanism A or B per event, over a
  low-level `fireEvent.custom(instance, eventKey, ...)` escape hatch.
- Everything downstream depends only on `fireEvent`'s interface; if react-lua
  ever hides the internals object, the swap is contained to one module (the
  fallback is a clean-room listener registry patched into the host config at
  test setup).
- react-roblox version pinned by Wally resolution to 17.2.1 (jsdotlua). The
  internals used here exist in that version; re-verify on upgrades.
