--!nonstrict
-- Phase 0 spike: validates the event-dispatch mechanisms fireEvent will build
-- on (see PLAN.md and docs/EVENT_DISPATCH.md). This file is throwaway — it is
-- excluded from prod builds and will be deleted once fireEvent lands in
-- Phase 3.
--
-- Mechanisms under test:
--   A. Listener invocation via ReactRoblox's SECRET_INTERNALS
--      (getFiberCurrentPropsFromNode) for events with no user-Luau trigger
--      (Activated, MouseButton1Click, ...).
--   B. Real engine triggers where user Luau can cause the actual signal
--      (TextBox.Text property set -> Change.Text handler).
--   C. Informational probes: VirtualInputManager availability and
--      CaptureFocus behavior in this environment.

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local afterEach = JestGlobals.afterEach

local act = ReactRoblox.act

local SECRET_INTERNALS_KEY = "__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED"

type AnyFn = (...any) -> ...any

local function getEventHandler(instance: Instance, eventKey: any): AnyFn?
	local internals = (ReactRoblox :: any)[SECRET_INTERNALS_KEY]
	if internals == nil or internals.Events == nil then
		return nil
	end
	local props = internals.Events.getFiberCurrentPropsFromNode(instance)
	if props == nil then
		return nil
	end
	return props[eventKey]
end

local roots: { any } = {}
local containers: { Instance } = {}

local function renderIntoContainer(element)
	local container = Instance.new("Folder")
	local root = ReactRoblox.createRoot(container)
	act(function()
		root:render(element)
	end)
	table.insert(roots, root)
	table.insert(containers, container)
	return container
end

afterEach(function()
	for _, root in roots do
		act(function()
			root:unmount()
		end)
	end
	for _, container in containers do
		container:Destroy()
	end
	table.clear(roots)
	table.clear(containers)
end)

describe("mechanism A: listener invocation via SECRET_INTERNALS", function()
	it("finds the Activated handler through getFiberCurrentPropsFromNode", function()
		local wasCalled = false

		local container = renderIntoContainer(React.createElement("TextButton", {
			Text = "Click me",
			[React.Event.Activated] = function()
				wasCalled = true
			end,
		}))

		local button = container:FindFirstChildOfClass("TextButton")
		expect(button).never.toBeNil()

		local handler = getEventHandler(button :: Instance, React.Event.Activated)
		expect(typeof(handler)).toBe("function")

		act(function()
			(handler :: AnyFn)(button)
		end)

		expect(wasCalled).toBe(true)
	end)

	it("drives a useState update through a synthesized Activated", function()
		local function Counter()
			local count, setCount = React.useState(0)
			return React.createElement("TextButton", {
				Text = `Count: {count}`,
				[React.Event.Activated] = function()
					setCount(function(current)
						return current + 1
					end)
				end,
			})
		end

		local container = renderIntoContainer(React.createElement(Counter))
		local button = container:FindFirstChildOfClass("TextButton") :: TextButton
		expect(button.Text).toBe("Count: 0")

		local handler = getEventHandler(button, React.Event.Activated)
		expect(typeof(handler)).toBe("function")

		act(function()
			(handler :: AnyFn)(button)
		end)

		expect(button.Text).toBe("Count: 1")
	end)

	it("sees handler updates after a rerender (props are not stale)", function()
		local hits: { string } = {}

		local function makeElement(tag: string)
			return React.createElement("TextButton", {
				Text = "Click me",
				[React.Event.Activated] = function()
					table.insert(hits, tag)
				end,
			})
		end

		local container = Instance.new("Folder")
		local root = ReactRoblox.createRoot(container)
		table.insert(roots, root)
		table.insert(containers, container)

		act(function()
			root:render(makeElement("first"))
		end)
		act(function()
			root:render(makeElement("second"))
		end)

		local button = container:FindFirstChildOfClass("TextButton") :: TextButton
		local handler = getEventHandler(button, React.Event.Activated)
		expect(typeof(handler)).toBe("function")

		act(function()
			(handler :: AnyFn)(button)
		end)

		expect(hits).toEqual({ "second" })
	end)
end)

describe("mechanism B: real engine triggers", function()
	it("fires Change.Text for real when TextBox.Text is set from Luau", function()
		local observed: { string } = {}

		local container = renderIntoContainer(React.createElement("TextBox", {
			Text = "",
			[React.Change.Text] = function(rbx: TextBox)
				table.insert(observed, rbx.Text)
			end,
		}))

		local box = container:FindFirstChildOfClass("TextBox") :: TextBox

		act(function()
			box.Text = "hello"
		end)

		expect(observed).toEqual({ "hello" })
	end)
end)

describe("environment probes (informational, always pass)", function()
	it("reports VirtualInputManager availability", function()
		local getServiceOk, serviceOrErr = pcall(function()
			return game:GetService("VirtualInputManager")
		end)

		if not getServiceOk then
			print(`[spike] VirtualInputManager: GetService failed -> {serviceOrErr}`)
			return
		end

		local sendOk, sendErr = pcall(function()
			-- Coordinates are irrelevant; we only care whether the call is
			-- permitted at this security level.
			(serviceOrErr :: any):SendMouseButtonEvent(0, 0, 0, true, nil, 1)
		end)
		print(
			`[spike] VirtualInputManager: GetService ok; SendMouseButtonEvent {if sendOk
				then "PERMITTED"
				else `DENIED -> {sendErr}`}`
		)
	end)

	it("reports whether CaptureFocus reaches a Focused handler here", function()
		local focused = false
		local focusLost = false

		local screenGui = Instance.new("ScreenGui")
		local parentOk, parentErr = pcall(function()
			screenGui.Parent = game:GetService("CoreGui")
		end)
		if not parentOk then
			print(`[spike] focus probe: cannot parent to CoreGui -> {parentErr}`)
			screenGui:Destroy()
			return
		end

		local root = ReactRoblox.createRoot(screenGui)
		table.insert(roots, root)
		table.insert(containers, screenGui)

		act(function()
			root:render(React.createElement("TextBox", {
				Text = "",
				[React.Event.Focused] = function()
					focused = true
				end,
				[React.Event.FocusLost] = function()
					focusLost = true
				end,
			}))
		end)

		local box = screenGui:FindFirstChildOfClass("TextBox") :: TextBox

		local captureOk, captureErr = pcall(function()
			act(function()
				box:CaptureFocus()
			end)
			act(function()
				box:ReleaseFocus()
			end)
		end)

		if captureOk then
			print(`[spike] focus probe: CaptureFocus ok; Focused fired = {focused}; FocusLost fired = {focusLost}`)
		else
			print(`[spike] focus probe: CaptureFocus errored -> {captureErr}`)
		end
	end)
end)

return nil
