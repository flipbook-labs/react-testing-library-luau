--!strict

-- Internal registry of live roots so cleanup() can unmount everything a test
-- rendered, even on failure paths that never reach unmount().

local ReactRoblox = require("@pkg/ReactRoblox")

export type Entry = {
	root: ReactRoblox.RootType,
	container: Instance,
	-- True when render() created the container itself and owns its lifetime.
	ownsContainer: boolean,
}

local entries: { Entry } = {}

local function register(entry: Entry)
	table.insert(entries, entry)
end

local function unregister(root: ReactRoblox.RootType)
	for index, entry in entries do
		if entry.root == root then
			table.remove(entries, index)
			return
		end
	end
end

local function drain(): { Entry }
	local current = table.clone(entries)
	table.clear(entries)
	return current
end

return {
	register = register,
	unregister = unregister,
	drain = drain,
}
