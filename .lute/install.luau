local process = require("@std/process")

local project = require("@repo/project")

-- Install Loom dependencies first since the rest of the script depends on them.
do
	local res = process.run({ "lute", "pkg", "install" }, {
		stdio = "inherit",
	})
	assert(res.ok, res.stderr)
end

do
	local FlipbookBatteries = require("@luaupkg/FlipbookBatteries@v0.10.1")
	local run = FlipbookBatteries.run

	local function installWallyPackages()
		run("wally", { "install" })
		run("rojo", { "sourcemap", project.ROJO_BUILD_PROJECT, "-o", "sourcemap.json" })
		run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })
	end

	installWallyPackages()
end
