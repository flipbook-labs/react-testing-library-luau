return {
	package = {
		name = "ReactTestingLibraryLuau",
		version = "0.2.0",
		-- `modules/.config.luau` is hidden, so it has to be named to ship. The
		-- exclusions match what the prod build prunes from `dist/`.
		files = {
			"/modules/**",
			"!/modules/**/*.spec.luau",
			"!/modules/**/jest.config.luau",
			"!/modules/**/examples/**",
			"/modules/.config.luau",
			"/README.md",
			"/LICENSE",
		},
		dependencies = {
			["flipbook-batteries"] = {
				rev = "v0.13.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
		},
		dev_dependencies = {
			["agent-skills"] = {
				rev = "v0.9.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
