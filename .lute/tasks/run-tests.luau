--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ReactRoblox.act is only exported when the mock scheduler global is enabled,
-- and it must be set before Jest (and transitively React) is required.
_G.__ROACT_17_MOCK_SCHEDULER__ = true

local Jest = (require :: any)(ReplicatedStorage.Packages.Jest)

local Packages = ReplicatedStorage.Packages
local library = Packages.ReactTestingLibraryLuau
local roots = { library.InstanceTesting, library.ReactTesting }

local status, result = Jest.runCLI(library.ReactTesting, {
	verbose = false,
	ci = false,
	-- selene: allow(global_usage)
	testPathPattern = _G.__JEST_TEST_PATH_PATTERN__,
}, roots):awaitStatus()

if status == "Rejected" then
	print(result)
end

if status ~= "Resolved" or result.results.numFailedTestSuites > 0 or result.results.numFailedTests > 0 then
	error(1)
end

return nil
