-- Simulates events on rendered instances. Two mechanisms, chosen per event
-- (see docs/EVENT_DISPATCH.md):
--
--   A. Listener invocation — look up the handler react-roblox registered for
--      the event prop and call it directly, wrapped in act. Used for pointer
--      events, which user-level Luau cannot trigger for real.
--   B. Real engine triggers — where Luau can cause the actual signal
--      (property sets, CaptureFocus), do that; react-roblox's own connection
--      runs the handler.
--
-- Event names are Roblox event names (activated, textChanged), not DOM names.

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local reactInternals = require("./reactInternals")

local act = ReactRoblox.act

--- Invokes the handler registered for the given React.Event.* / React.Change.*
--- key, inside act. The escape hatch behind every typed helper; use it for
--- events without one (e.g. `fireEvent.custom(frame, React.Event.TouchTap)`).
--- Returns true if a handler was registered and invoked.
local function custom(instance: Instance, eventKey: unknown, ...: unknown): boolean
	local handler = reactInternals.getRegisteredHandler(instance, eventKey)
	if handler == nil then
		return false
	end

	local args = table.pack(...)
	act(function()
		handler(instance, table.unpack(args, 1, args.n))
	end)
	return true
end

-- Mechanism A helpers ------------------------------------------------------

local function activated(instance: GuiButton)
	custom(instance, React.Event.Activated)
end

local function mouseButton1Click(instance: GuiButton)
	custom(instance, React.Event.MouseButton1Click)
end

local function mouseButton2Click(instance: GuiButton)
	custom(instance, React.Event.MouseButton2Click)
end

local function mouseEnter(instance: GuiObject)
	-- Real MouseEnter reports the mouse position; the element center is the
	-- conventional stand-in.
	local center = instance.AbsolutePosition + instance.AbsoluteSize / 2
	custom(instance, React.Event.MouseEnter, center.X, center.Y)
end

local function mouseLeave(instance: GuiObject)
	local position = instance.AbsolutePosition
	custom(instance, React.Event.MouseLeave, position.X - 1, position.Y - 1)
end

-- Mechanism B helpers ------------------------------------------------------

local function textChanged(instance: TextBox, text: string)
	act(function()
		instance.Text = text
	end)
end

local function focus(instance: TextBox)
	act(function()
		instance:CaptureFocus()
	end)
end

--- Releases focus. The engine does not reliably deliver FocusLost in headless
--- DataModels (verified by the Phase 0 spike), so if the real signal did not
--- reach the handler we invoke it directly with enterPressed = false.
local function blur(instance: TextBox)
	local delivered = false
	local connection = instance.FocusLost:Connect(function()
		delivered = true
	end)

	act(function()
		instance:ReleaseFocus()
	end)
	connection:Disconnect()

	if not delivered then
		custom(instance, React.Event.FocusLost, false, nil)
	end
end

return {
	custom = custom,

	activated = activated,
	mouseButton1Click = mouseButton1Click,
	mouseButton2Click = mouseButton2Click,
	mouseEnter = mouseEnter,
	mouseLeave = mouseLeave,

	textChanged = textChanged,
	focus = focus,
	blur = blur,
}
