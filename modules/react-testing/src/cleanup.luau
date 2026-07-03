-- Unmounts every root render() created and destroys the containers it owns.
-- Call from afterEach (or use installCleanup) so a failed test never leaks
-- mounted UI into the next one.

local ReactRoblox = require("@pkg/ReactRoblox")

local mountedRoots = require("./mountedRoots")

local act = ReactRoblox.act

local function cleanup()
	for _, entry in mountedRoots.drain() do
		act(function()
			entry.root:unmount()
		end)
		if entry.ownsContainer then
			entry.container:Destroy()
		end
	end
end

--- Registers cleanup with the test framework's afterEach, e.g.:
---
---   ReactTesting.installCleanup(JestGlobals.afterEach)
local function installCleanup(afterEach: (callback: () -> ()) -> ())
	afterEach(cleanup)
end

return {
	cleanup = cleanup,
	installCleanup = installCleanup,
}
