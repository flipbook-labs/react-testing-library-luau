local FlipbookBatteries = require("@luaupkg/FlipbookBatteries@v0.10.1")
local cli = require("@batteries/cli")
local fs = require("@std/fs")

local project = require("@repo/project")

local find = FlipbookBatteries.find
local mkdir = FlipbookBatteries.mkdir
local rmdir = FlipbookBatteries.rmdir
local run = FlipbookBatteries.run

local args = cli.parser()

args:add("channel", "option", {
	help = "channel to build for",
	aliases = { "c" },
	default = "prod",
})

args:parse({ ... })

local channel = args:get("channel")
assert(channel == "dev" or channel == "prod", `bad value for channel (must be one of "dev" or "prod", got "{channel}")`)

local PRUNED_FILE_PATTERNS = {
	"%.spec%.luau",
	"jest%.config%.luau",
	"examples",
}

local function build()
	if fs.exists(project.BUILD_PATH) and fs.type(project.BUILD_PATH) == "dir" then
		rmdir(project.BUILD_PATH)
	end
	mkdir(project.BUILD_PATH)

	run("rojo", {
		"sourcemap",
		project.ROJO_BUILD_PROJECT,
		"-o",
		project.DARKLUA_SOURCEMAP_PATH,
	})

	for _, pkg in project.PACKAGES do
		run("darklua", {
			"process",
			pkg.sourcePath,
			pkg.buildPath,
		})
	end

	if channel == "prod" then
		for _, prunedFilePattern in PRUNED_FILE_PATTERNS do
			local prunedFiles = find(project.BUILD_PATH, prunedFilePattern)
			for _, specFile in prunedFiles do
				fs.remove(specFile)
			end
		end
	end
end

build()
