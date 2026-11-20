local process = require("@std/process")

local project = require("@repo/project")

local function run(command: { string })
	local result = process.run(command, { stdio = "inherit" })
	assert(result.ok, `{table.concat(command, " ")} failed`)
end

-- Installs the dependencies in `pkg.luau`. `--vendor` copies each one into a
-- `.lpm/<key>@<rev>` folder, and the `lpm` alias in `.config.luau` points at
-- `.lpm`. When a vendored package requires through `@lpm`, the require uses
-- the `lpm` alias of whichever project vendored it. So any project that
-- vendors such a package has to define the same alias.
-- The following issue tracks removing that requirement:
-- https://github.com/flipbook-labs/flipbook/issues/694
run({ "lute", "pkg", "install", "--vendor" })

run({ "wally", "install" })
run({ "rojo", "sourcemap", project.ROJO_BUILD_PROJECT, "-o", "sourcemap.json" })
run({ "wally-package-types", "--sourcemap", "sourcemap.json", "Packages" })
