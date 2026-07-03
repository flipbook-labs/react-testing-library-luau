local FlipbookBatteries = require("@luaupkg/FlipbookBatteries@v0.10.1")
local path = require("@std/path")
local system = require("@std/system")

local project = require("@repo/project")

local run = FlipbookBatteries.run

local globalDefsPath = path.join(system.tmpdir(), "globalTypes.d.luau")

run("curl", {
	"-s",
	"-o",
	globalDefsPath,
	"-O",
	"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua",
})

local function analyzeLuauSource()
	run("luau-lsp", {
		"analyze",
		`--defs={globalDefsPath}`,
		"--settings=./.vscode/settings.json",
		"--platform=standard",
		"--flag:LuauSolverV2=true",
		project.LUTE_SCRIPTS_PATH,
	})
end

local function analyzeRobloxSource()
	run("rojo", {
		"sourcemap",
		project.ROJO_BUILD_PROJECT,
		"-o",
		project.SOURCEMAP_PATH,
	})

	for _, pkg in project.PACKAGES do
		run("luau-lsp", {
			"analyze",
			`--sourcemap={project.SOURCEMAP_PATH}`,
			`--defs={globalDefsPath}`,
			"--settings=./.vscode/settings.json",
			pkg.sourcePath,
		})
	end
end

analyzeLuauSource()
analyzeRobloxSource()
