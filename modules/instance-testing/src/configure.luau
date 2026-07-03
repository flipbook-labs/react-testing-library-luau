--!strict

export type Config = {
	--- Prefix for the CollectionService tag that carries an instance's test id.
	--- An instance with tag `data-testid=submit-button` has test id
	--- "submit-button". Matches the convention used by Roblox's
	--- dom-testing-library-lua port.
	testIdAttribute: string,
}

export type ConfigOverrides = {
	testIdAttribute: string?,
}

local config: Config = {
	testIdAttribute = "data-testid",
}

local function configure(overrides: ConfigOverrides)
	if overrides.testIdAttribute ~= nil then
		config.testIdAttribute = overrides.testIdAttribute
	end
end

local function getConfig(): Config
	return config
end

return {
	configure = configure,
	getConfig = getConfig,
}
