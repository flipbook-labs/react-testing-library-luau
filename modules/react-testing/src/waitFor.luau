--!strict

-- Polls a callback until it stops throwing or the timeout elapses (in
-- seconds, matching task.wait). Ported from storyteller's test-utils, with
-- one addition: each attempt first flushes pending React work. Under the
-- mock scheduler (jest), state updates made outside act — timer callbacks,
-- signal handlers — are queued but never rendered until something flushes
-- them; without this, findBy* would poll a permanently stale tree. This is
-- the same role RTL-js's asyncWrapper/act integration plays.

local ReactRoblox = require("@pkg/ReactRoblox")

export type WaitForOptions = {
	timeout: number?,
	interval: number?,
}

local DEFAULT_TIMEOUT = 1
local DEFAULT_INTERVAL = 0.05

local function flushReactWork()
	ReactRoblox.act(function() end)
end

local function waitFor(callback: () -> (), options: WaitForOptions?)
	local timeout = if options ~= nil and options.timeout ~= nil then options.timeout else DEFAULT_TIMEOUT
	local interval = if options ~= nil and options.interval ~= nil then options.interval else DEFAULT_INTERVAL

	local lastError: unknown
	local elapsed = 0

	while true do
		flushReactWork()
		-- The explicit unknown return gives pcall's second result a type; a
		-- bare `pcall(callback)` types as returning only the boolean.
		local ok, err = pcall(function(): unknown
			callback()
			return nil
		end)

		if ok then
			return
		end

		lastError = err

		if elapsed >= timeout then
			-- Vetted unknown cast: pcall's error value is opaque; stringify for
			-- the thrown message.
			error(tostring(lastError), 2)
		end

		elapsed += task.wait(interval)
	end
end

return waitFor
