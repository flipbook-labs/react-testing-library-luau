-- The single dynamic boundary onto react-roblox's test internals. Everything
-- here is `unknown`-vetted: react-roblox exports the internals object (the
-- same channel upstream React DOM exposes for testing tools — RTL-js depends
-- on its equivalent) but publishes no types for it, so we declare the minimal
-- shape we consume and verify with runtime checks. Validated against
-- react-roblox 17.2.1 by the Phase 0 spike; see docs/EVENT_DISPATCH.md.

local ReactRoblox = require("@pkg/ReactRoblox")

--- A handler registered for a host event prop. react-roblox invokes these as
--- `handler(instance, ...eventArgs)` (see SingleEventManager), and so do we.
export type EventHandler = (instance: Instance, ...unknown) -> ()

local SECRET_INTERNALS_KEY = "__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED"

type UnknownMap = { [unknown]: unknown }

-- Vetted unknown cast: dynamic indexing chokepoint for the untyped internals.
local function index(value: unknown, key: unknown): unknown
	if typeof(value) ~= "table" then
		return nil
	end
	return (value :: UnknownMap)[key]
end

--- Returns the props table react-roblox currently associates with a host
--- instance, or nil if the instance is not a mounted host component.
--- Keys are React.Event.* / React.Change.* key objects and plain prop names.
local function getCurrentProps(instance: Instance): UnknownMap?
	local internals = index(ReactRoblox, SECRET_INTERNALS_KEY)
	local events = index(internals, "Events")
	local getFiberCurrentPropsFromNode = index(events, "getFiberCurrentPropsFromNode")

	if typeof(getFiberCurrentPropsFromNode) ~= "function" then
		error(
			"react-roblox no longer exposes Events.getFiberCurrentPropsFromNode through its internals object. "
				.. "fireEvent cannot work against this react-roblox version; see docs/EVENT_DISPATCH.md.",
			0
		)
	end

	-- Vetted unknown cast: callability is established by the guard above;
	-- typeof checks do not narrow `unknown` to a callable type.
	local getProps = getFiberCurrentPropsFromNode :: (Instance) -> unknown

	local props = getProps(instance)
	if typeof(props) ~= "table" then
		return nil
	end
	return props :: UnknownMap
end

--- Looks up the handler registered for `eventKey` (a React.Event.* or
--- React.Change.* key object) on a mounted host instance.
local function getRegisteredHandler(instance: Instance, eventKey: unknown): EventHandler?
	local props = getCurrentProps(instance)
	if props == nil then
		return nil
	end

	local handler = props[eventKey]
	if typeof(handler) ~= "function" then
		return nil
	end

	-- Vetted unknown cast: handler props are functions by construction
	-- (react-roblox connected them to the event); the runtime check above
	-- guarantees callability.
	return handler :: EventHandler
end

return {
	getCurrentProps = getCurrentProps,
	getRegisteredHandler = getRegisteredHandler,
}
