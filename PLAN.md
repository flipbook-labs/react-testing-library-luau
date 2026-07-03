# React Testing Library for Luau — Project Plan

## Context

flipbook-labs builds React-based Roblox UI (flipbook, storyteller) but has no comprehensive component-testing library — storyteller carries only minimal `renderHook`/`waitFor` utilities. Roblox's source-available ports of react-testing-library (v12.1.5) and dom-testing-library (v8.14.0) exist and are MIT-licensed, but they are verbatim JS transpilations: they lean on LuauPolyfill, lose type information through object merges, and split across two repos with Rotriever packaging that doesn't fit the flipbook-labs toolchain.

**Goal:** a new flipbook-labs repo containing an idiomatic-Luau, RTL-inspired testing library for react-lua — dom-testing-library functionality folded into the same repo — assembled as a Loom workspace of path-dependency packages, typed strictly with **zero `any` casts** (tightly-vetted `unknown` only), tested via the org's existing jest + rocale-cli cloud-execution pattern, and executable to completion by an Opus model following this plan.

### Fixed decisions (from user)

- **Runtime:** tests run inside Roblox Studio / a live DataModel against real Instances (org test infra runs in Open Cloud Luau execution sessions — also a live DataModel).
- **API:** idiomatic Luau, RTL-inspired (render / queries / fireEvent / waitFor mental model) — not a verbatim port. Luau-native signatures instead of JS object-merge options.
- **Home:** new repo in the flipbook-labs org; DTL functionality folded in rather than a separate dependency repo.
- **Packaging:** Loom workspace (`lute pkg`, `loom.config.luau`) with path dependencies between packages; dual wally.toml for publishing, per org convention.

## Research findings (verified)

### VirtualInput is off the table
`VirtualInputManager` / `VirtualInput` are RobloxScriptSecurity, internal-only benchmarking services — unusable from plugins, the command bar, and Open Cloud Luau execution sessions (the Phase 0 spike confirmed `GetService("VirtualInputManager")` throws "not a valid Service name" in a cloud session). RBXScriptSignals also cannot be fired from user Luau. **Event simulation must invoke the React-registered listeners directly**, not engine-level input.

**Phase 0 correction to earlier research:** Roblox's `dom-testing-library-lua` fireEvent (`src/jsHelpers/dispatchEvent.lua`) is built ON VirtualInputManager (`SendMouseButtonEvent`, `SendKeyEvent`, ...) — it only works in Roblox's internal elevated-permission test infra, and is therefore unusable as-is by community consumers. This makes this library the only workable approach outside Roblox, not just a re-typing.

**Phase 0 outcome (COMPLETE — all spike tests passed in a live cloud DataModel, see `docs/EVENT_DISPATCH.md`):**
- Mechanism A: `ReactRoblox.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.Events.getFiberCurrentPropsFromNode(instance)` → `props[React.Event.Foo]` → invoke handler inside `ReactRoblox.act`. Verified: handler found, state updates flow, rerenders don't leave stale handlers.
- Mechanism B: real engine triggers work — `TextBox.Text` set fires `Change.Text` handler; `CaptureFocus()` fires `Focused` even headless. `ReleaseFocus()` did NOT fire `FocusLost` in the cloud session (Phase 3 must investigate; fallback is mechanism A).

### Reference implementations
| Repo | License | Status | Notes |
|---|---|---|---|
| Roblox/react-testing-library-lua | MIT | Active (Jun 2025) | RTL v12.1.5 port; `fire-event.lua`, `act-compat.lua`; wraps DTL fireEvent with React-specific event mappings |
| Roblox/dom-testing-library-lua | MIT | Very active (Nov 2025; added drag/mouseMove/mouseDown/mouseUp) | DTL v8.14.0 port; queries: ByText, ByPlaceholderText, ByDisplayValue, ByTestId (ByRole/ByLabelText/ByTitle/ByAltText unportable — no accessibility tree); testId via CollectionService tag `data-testid=<value>`; text via `.Text`; class-name arrays instead of CSS selectors; `jsHelpers/dispatchEvent.lua` |
| jsdotlua/react-testing-library-lua | MIT | Inactive (Sep 2024) | Ignore except as wally-packaging reference |
| Kampfkarren/react-roblox-fire-event | **MPL-2.0** | Minimal | Do **not** copy code; approach (callback registry patching react-roblox, no VirtualInput) is instructive |

MIT licensing on both Roblox repos means we can freely adapt logic and port test cases while redesigning the API and types.

### Loom / Lute (verified against lute source + local repos)
- `lute` 1.0.1-nightly installed via Rokit; `lute pkg install` resolves into `.lute/`; `lute run/check/lint/test` available.
- `loom.config.luau` shape (from `lute/cli/commands/pkg/loom-core/src/manifest.luau`): `{ package = { name, version, dependencies = { Key = {...} }, devDependencies = {...} } }` with `sourceKind = "path" | "github" | "registry"`. Path deps: `{ sourceKind = "path", source = "../lib" }` (optional `name` override). Proven monorepo fixture: lute's own `tests/src/packages/pkgrun_deep_path_deps/packages/{app,lib,shared}`. Lockfile: `loom.lock.luau`.

### Org conventions (from sibling repos)
- Dual manifests (`loom.config.luau` + `wally.toml`), publish to Wally; `src/` → built `dist/`; lute task scripts under `.lute/` (`build.luau`, `test.luau`, `lint.luau`, `install.luau`, `tasks/`).
- Testing: `jsdotlua/jest@3.10.0` + jest-globals, `*.spec.luau` next to source, executed through **rocale-cli** (Open Cloud Luau execution against `ROBLOX_UNIT_TESTING_PLACE_ID`); harness pattern in `agent-gateway/.lute/tasks/run-tests.luau` + `.lute/test.luau`.
- React stack: `jsdotlua/react@17.0.2` + `react-roblox@17.0.2` (flipbook, storyteller).
- In-Studio e2e pattern exists: `agent-gateway/.agents/skills/e2e/SKILL.md` (build plugin → install → drive via gateway). Runbooks live in `.agents/skills/<name>/SKILL.md`.
- Linting: selene (`std = "roblox+luau"`) + stylua. This repo raises the bar to strict-mode typechecking on every file (`.luaurc` `languageMode = "strict"`; no per-file directives).

## Key design decisions

| Decision | Choice | Rationale |
|---|---|---|
| Repo name | `flipbook-labs/react-testing-library-luau` | Signals lineage + platform; final name adjustable at bootstrap |
| Package split | Two packages: `modules/instance-testing` (folded DTL: queries over plain Instances, no React dep) + `modules/react-testing` (render/fireEvent/act/waitFor, path-depends on the former) | Queries are useful standalone (Roact/Fusion UIs too); matches the DTL→RTL layering; exercises the Loom path-dep workspace |
| Dependency channels | Loom for lute/batteries tooling + path deps between our packages; **React/ReactRoblox/Jest via Wally** (`wally.toml` dev-deps) like every sibling repo | Loom's `registry` sourceKind exists but no org repo uses it for jsdotlua packages; don't pioneer that here |
| Wally publishing | Single package `flipbook-labs/react-testing-library-luau` containing both layers in `dist/` | One artifact for v0.1; split later if standalone query demand appears |
| Event simulation | Hybrid: **real engine triggers where user Luau can cause them** (set `TextBox.Text` → real Changed/TextChanged; `CaptureFocus()`/`ReleaseFocus()` → real Focused/FocusLost) + **direct listener invocation** for pointer events (Activated, MouseButton1Click, MouseEnter/Leave) which have no user-Luau trigger. Exact listener-lookup mechanism resolved by the Phase 0 spike | VirtualInput is unusable; RBXScriptSignals can't be fired from Luau; real triggers where possible = highest fidelity |
| Event names | Roblox event names (`Activated`, `FocusLost`), not DOM names (`click`, `blur`) | Idiomatic; no misleading DOM aliases |
| fireEvent typing | `fireEvent(instance, eventName, ...)` low-level with vetted `unknown` varargs, plus a typed sugar namespace: `fireEvent.activated(button)`, `fireEvent.textChanged(box, "new text")`, `fireEvent.focus(box)`, `fireEvent.hover(frame)` | Zero `any`; the typed helpers are the documented API, varargs form is the escape hatch |
| `screen` global | **None.** Queries come from `render()`'s result and `within(instance)` | No global document exists in Roblox; scoped queries are honest and avoid global mutable state |
| Async | `waitFor` via `task.wait` polling (storyteller's pattern, jest-fake-timer compatible); `findBy*` = query + waitFor. No Promise library | Fewer deps, simpler types |
| Options objects | Explicit named types (`RenderOptions`, `TextMatchOptions`), no merge helpers | This is where verbatim ports lose type info |
| Typing bar | strict mode on every file via the root `.luaurc` (no per-file directives); zero `any`; `unknown` only at true dynamic boundaries (event varargs, error values), each cast commented | User requirement |
| LuauPolyfill | Not used in our source (react pulls it transitively; that's fine) | Avoid JS-isms and the polyfill's Roblox-API entanglement |
| Test runner | jsdotlua/jest 3.10.0 via the org's rocale-cli Open Cloud harness (copy `agent-gateway/.lute/{test.luau,tasks/run-tests.luau}`) | Org convention; runs in a live DataModel |

## Implementation plan

Executed phase by phase; every phase gates on: `lute run check` (strict typecheck), `lute run lint` (selene + stylua), and jest specs green via `lute run test` (needs `ROBLOX_API_KEY` + unit-testing place, same env as agent-gateway).

### Phase 0 — Event-dispatch spike (gates everything)

The one real technical risk: how to reach the handlers react-roblox registered on a host Instance.

1. Read the MIT reference sources: `Roblox/dom-testing-library-lua` `src/jsHelpers/dispatchEvent.lua` + `src/event-map.lua`, and `Roblox/react-testing-library-lua` `src/fire-event.lua`, `src/act-compat.lua`. Establish exactly how they look up listeners (fiber props? instance→fiber map? react-roblox internals?).
2. Read jsdotlua/react-roblox 17.0.2 host-config source: where `Activated = fn` props become `:Connect` calls and whether an instance→props/fiber mapping is reachable from public or semi-public exports.
3. Prototype in a scratch spec (temporary `modules/spike/`), run through the rocale-cli harness:
   - Render `TextButton` with `Activated` handler → invoke it via the chosen mechanism → assert called.
   - Set `TextBox.Text` directly → assert a `Changed`/`GetPropertyChangedSignal`-driven React handler fires for real.
   - `TextBox:CaptureFocus()` / `ReleaseFocus()` → assert `Focused`/`FocusLost` handlers fire for real (validates the hybrid strategy in a cloud DataModel).
4. Write `docs/EVENT_DISPATCH.md`: chosen mechanism, react-roblox internals touched, per-event table (real-trigger vs listener-invocation), limitations.

Fallbacks if fiber/props lookup is inaccessible: (a) a listener registry populated by patching react-roblox's host config at test-setup time (Kampfkarren's *approach*, MPL code not copied — clean-room reimplementation); (b) pin/upgrade react-roblox version if internals moved.

### Phase 1 — Repo bootstrap

Create `flipbook-labs/react-testing-library-luau` mirroring agent-gateway's scaffolding:

```
react-testing-library-luau/
├── packages/
│   ├── instance-testing/        # folded dom-testing-library
│   │   ├── loom.config.luau     # name = "InstanceTesting"; deps: Lute (github)
│   │   └── src/
│   └── react-testing/
│       ├── loom.config.luau     # name = "ReactTesting"; deps: InstanceTesting (path ../instance-testing), Lute
│       └── src/
├── loom.config.luau             # repo tooling deps (Lute, FlipbookBatteries) — root is its own package, like sibling repos
├── wally.toml                   # publish manifest; dev-deps: jsdotlua React/ReactRoblox/Jest/JestGlobals
├── *.project.json               # rojo: default/build/tests (copy agent-gateway pattern)
├── .luaurc / selene.toml / stylua.toml   # mirror agent-gateway; strict mode
├── .lute/{install,check,lint,build,test}.luau + tasks/run-tests.luau   # copy + adapt from agent-gateway
├── .github/workflows/{test,release}.yml
└── docs/
```

Bootstrap-time verifications (things intentionally left to confirm by doing, with fallbacks):
- Where `loom.lock.luau` lands with path deps (lute's fixture has per-repo-root lock; run `lute pkg install` in each package and commit whatever locks appear).
- Exact `.luaurc` aliases — copy agent-gateway's and adjust; confirm `@pkg` resolution for Wally packages in the tests rojo project.
- Reuse agent-gateway's `ROBLOX_UNIT_TESTING_PLACE_ID`/universe env or provision a new place (ask Marin for the API key/place if not in env).

Gate: `lute run check` + `lint` pass on stub `init.luau` files; CI green on a no-op spec.

### Phase 2 — `instance-testing`: queries over Instances

Port DTL-lua's behavior, redesigned types. Files under `modules/instance-testing/src/`:

- `types.luau` — `TextMatch = string | (string, Instance) -> boolean` (no RegExp type; Luau has `string.match` — accept Lua patterns via option), `TextMatchOptions = { exact: boolean?, pattern: boolean?, normalizer: ((string) -> string)? }`, `QueryVariants<Args...>` generics if expressible, else explicit six-variant types per query.
- `queries/text.luau` — match `.Text` on TextLabel/TextButton/TextBox descendants; whitespace-normalized by default.
- `queries/testId.luau` — CollectionService tag `data-testid=<value>` (compatible with Roblox DTL convention; configurable via `configure`).
- `queries/placeholderText.luau`, `queries/displayValue.luau` — TextBox.PlaceholderText / .Text.
- Each query exposes `get/getAll/query/queryAll` (sync); `find/findAll` live in the react layer (they need waitFor).
- `within.luau` — binds all variants to a container; the primary ergonomic entry point.
- `prettyInstanceTree.luau` — ASCII tree for error messages (query failures embed it, like prettyDOM).
- `configure.luau` — `{ testIdAttribute: string? }` module-level config.
- Intentionally omitted: ByRole/ByLabelText/ByTitle/ByAltText (no accessibility tree — documented as such).

Port relevant test cases from Roblox DTL specs (MIT) into `*.spec.luau` next to each module: found/not-found/multiple, nil-returning queryBy, exact/normalizer options, tag queries.

Gate: check + lint + specs green.

### Phase 3 — `react-testing`: render / fireEvent / act / waitFor

Files under `modules/react-testing/src/`:

- `types.luau` — `RenderOptions = { container: Instance? }`, `RenderResult = { container: Instance, unmount: () -> (), rerender: (React.ReactElement<any>?) -> () }` **plus** bound query methods (generated from instance-testing's `within`), typed explicitly. (If `React.ReactElement`'s own generics force an `any`, wrap in a local `ReactElement` alias at the react boundary with a vetted `unknown` and a comment — this is the one sanctioned dynamic boundary.)
- `render.luau` — `createRoot` into `options.container or Instance.new("ScreenGui")` parented to the test DataModel (CoreGui/place root per harness), wrapped in `ReactRoblox.act`; returns result with scoped queries + `unmount`/`rerender`; registers container for `cleanup()`.
- `cleanup.luau` — unmount all live roots + destroy containers; wire an opt-in `installCleanup(afterEach)` helper rather than magic globals.
- `fireEvent.luau` — Phase 0 mechanism: typed helpers (`activated`, `mouseButton1Click`, `mouseEnter`, `mouseLeave`, `textChanged`, `focus`, `blur`, plus what DTL-lua's Nov 2025 additions cover: `mouseMove`, `mouseDown`, `mouseUp`, `drag` if the mechanism supports them) over a low-level `fire(instance, eventName: string, ...unknown)`.
- `act.luau` — thin re-export of `ReactRoblox.act`.
- `waitFor.luau` — `waitFor(callback: () -> (), options: { timeout: number?, interval: number? }?)` polling via `task.wait`; port storyteller's implementation/tests (`storyteller/src/test-utils`).
- `queries/find.luau` — `findBy*`/`findAllBy*` = waitFor + sync query.

Specs: the counter scenario is the canonical acceptance test — render component with `useState`, `fireEvent.activated(getByText("Increment"))` inside act, `waitFor` text updates. Plus rerender, unmount, cleanup, focus/text-entry round-trip on TextBox.

Gate: check + lint + specs green — including the real click→state-change→re-query flow in the cloud DataModel.

### Phase 4 — Public API assembly + type audit

- `modules/react-testing/src/init.luau` exports: `render`, `cleanup`, `installCleanup`, `act`, `fireEvent`, `waitFor`, `within`, `prettyInstanceTree`, `configure`, and re-exported types.
- Type audit: grep for `:: any` (must be zero) and `:: unknown`/`unknown` (each needs a justifying comment); confirm every exported function has full explicit signatures. Add a CI lint step: `grep -rn ":: any" modules/*/src` fails the build.
- Smoke spec importing every export.

### Phase 5 — Docs + e2e skill

- `README.md` — philosophy (idiomatic vs the verbatim Roblox port), quick start (counter example), installation (Wally), honest limitations (no ByRole, no engine-level input, VirtualInput explanation).
- `docs/API.md` — full reference with Luau signatures; `docs/EVENT_DISPATCH.md` from Phase 0; `docs/migration-from-roblox-rtl.md` — table of API deltas (event names, options types, no screen/global).
- ~~`.agents/skills/e2e/SKILL.md`~~ — an in-Studio/agent-driven e2e runbook was built here and later **removed**: the library is unit-testing only, with no supported use outside a Jest context.
- All doc code samples extracted into a compiled spec (or at minimum `lute check`-ed) so examples can't rot at launch.

### Phase 6 — Publish + ecosystem

- `CHANGELOG.md`, MIT `LICENSE` (with attribution note that portions of test cases/behavior derive from Roblox's MIT ports), `release.yml` (on tag: build dist via darklua/rojo, `wally publish`).
- Verify no dependency on storyteller/flipbook (only React/ReactRoblox); file follow-up issues on storyteller to migrate its `renderHook`/`waitFor` consumers later (out of scope here).
- Draft PRs are the norm; repo creation and first push need Marin's confirmation of the final repo name.

## Verification (end-to-end)

1. `lute run check && lute run lint` — strict typecheck + selene/stylua across all packages.
2. `lute run test` — full jest suite through rocale-cli in a cloud DataModel (requires `ROBLOX_API_KEY`, unit-testing place ID — reuse agent-gateway's env).
3. Acceptance scenario (must pass in suite): render counter → `fireEvent.activated` → `waitFor(getByText("Count: 1"))` → unmount → container destroyed.
4. `grep -rn ":: any" modules/*/src` returns nothing; every `unknown` cast has a justification comment.

## Risks & open questions (each with owner strategy)

- **Listener lookup may require react-roblox internals** → Phase 0 spike decides between fiber/props lookup and clean-room host-config patching; everything downstream consumes only `fireEvent`'s interface, so the mechanism is swappable.
- **Loom lockfile/workspace behavior with path deps is under-documented** → confirm empirically at bootstrap; the lute fixture (`tests/src/packages/pkgrun_deep_path_deps`) is the reference.
- **`find*` under jest fake timers** → storyteller's waitFor already handles this pattern; port its approach and test both real and fake timers.
- **Cloud place vs Studio differences** (CoreGui access, focus behavior in headless sessions) → spike Phase 0 item 3 tests focus in the cloud DataModel; if focus only works in Studio, mark `fireEvent.focus` Studio-only in docs and cover it via the e2e skill instead.
- **jsdotlua react-roblox 17.0.2 pin** → matches flipbook/storyteller; upgrade only if the spike finds missing internals.
