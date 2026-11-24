return {
	categories = { "Features", "Changes", "Fixes", "Dependencies", "Internal" },
	collapsed = { "Dependencies", "Internal" },
	version = {
		current = "0.2.0",
		mirror = {
			{ file = "pkg.luau" },
			{ file = "wally.toml" },
			{ file = "README.md", pattern = "flipbook%-labs/react%-testing%-library%-luau@([%d%.]+)" },
		},
	},
	kind = {
		release = { text = "Release", color = "#94606f" },
		async = { text = "Async", color = "#1a7f37" },
		build = { text = "Build", color = "#5a7396" },
		ci = { text = "CI", color = "#75659a" },
		contributing = { text = "Contributing", color = "#5f7f55" },
		docs = { text = "Docs", color = "#8a5a2b" },
		events = { text = "Events", color = "#bf3989" },
		packages = { text = "Packages", color = "#7a7444" },
		queries = { text = "Queries", color = "#0969da" },
		render = { text = "Render", color = "#5b5bd6" },
		tooling = { text = "Tooling", color = "#4e8079" },
	},
}
