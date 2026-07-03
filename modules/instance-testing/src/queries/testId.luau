--!strict

-- Queries by test id, carried as a CollectionService tag of the form
-- `<testIdAttribute>=<value>` (default `data-testid=<value>`). Compatible
-- with the tagging convention of Roblox's dom-testing-library-lua port and
-- with react-lua's `ReactRoblox.Tag` prop.

local CollectionService = game:GetService("CollectionService")

local configure = require("../configure")
local queryEngine = require("../queryEngine")

local function getTestId(instance: Instance): string?
	local prefix = configure.getConfig().testIdAttribute .. "="
	local found: string? = nil
	for _, tag in CollectionService:GetTags(instance) do
		if string.sub(tag, 1, #prefix) == prefix then
			if found ~= nil then
				error(`Instance "{instance:GetFullName()}" has multiple {prefix}* tags`, 0)
			end
			found = string.sub(tag, #prefix + 1)
		end
	end
	return found
end

local function queryAllByTestId(container: Instance, testId: string, _options: nil): { Instance }
	return queryEngine.collectDescendants(container, function(descendant)
		return getTestId(descendant) == testId
	end)
end

local function describeMatcher(testId: string): string
	return `"{testId}"`
end

local variants = queryEngine.buildVariants(queryAllByTestId, "ByTestId", describeMatcher)

return {
	queryAll = variants.queryAll,
	query = variants.query,
	getAll = variants.getAll,
	get = variants.get,
	getTestId = getTestId,
}
