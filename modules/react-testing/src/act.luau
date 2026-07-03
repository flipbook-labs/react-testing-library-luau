-- Thin re-export. ReactRoblox.act requires `_G.__ROACT_17_MOCK_SCHEDULER__`
-- to be set before Jest/React load; the test runner does this.

local ReactRoblox = require("@pkg/ReactRoblox")

local function act(callback: () -> ()): ()
	ReactRoblox.act(callback)
end

return act
