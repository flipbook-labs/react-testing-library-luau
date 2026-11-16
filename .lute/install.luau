local fs = require("@std/fs")
local luau = require("@std/luau")
local process = require("@std/process")

local project = require("@repo/project")

local CONFIG_PATH = ".config.luau"
local LOCKFILE_PATH = "pkg.lock.luau"

-- `lute pkg install` puts each dependency in the Loom store, `~/.loom/store`,
-- under a folder whose name includes hashes of its source and rev. A dependency
-- with a `target` in `pkg.luau` installs only that subfolder, like Lute's
-- `batteries`. The lockfile records where each one landed, but `lute check` and
-- editors read aliases only from `.config.luau`. So after installing, this
-- copies each recorded path into that dependency's alias. Keys are aliases in
-- `.config.luau`, and values are dependency names in `pkg.luau`.
local DEPENDENCY_ALIASES: { [string]: string } = {
	batteries = "Lute",
	flipbookbatteries = "FlipbookBatteries",
}

type Lockfile = {
	dependencies: { [string]: string },
	devDependencies: { [string]: string }?,
	packages: { [string]: { installPath: string } },
}

-- FlipbookBatteries' `run` helper is one of the dependencies this script
-- installs, so it can't be required here.
local function run(command: { string })
	local result = process.run(command, {
		stdio = "inherit",
	})
	assert(result.ok, `{table.concat(command, " ")} failed`)
end

local function getStorePath(lockfile: Lockfile, name: string): string
	local key = lockfile.dependencies[name] or (lockfile.devDependencies and lockfile.devDependencies[name])
	assert(key, `{name} is not a dependency in {LOCKFILE_PATH}`)

	-- The lockfile writes `@pkg/` for the Loom store, unrelated to the `pkg`
	-- alias for Wally packages in `.config.luau`. The path of a dependency
	-- without a target ends in `/.`.
	local installPath = lockfile.packages[key].installPath
	return (installPath:gsub("^@pkg/", "~/.loom/store/"):gsub("/%.$", ""))
end

local function installLoomPackages()
	run({ "lute", "pkg", "install" })

	local lockfile: Lockfile = luau.loadModule(LOCKFILE_PATH)
	local config = fs.readFileToString(CONFIG_PATH)

	for alias, name in DEPENDENCY_ALIASES do
		local storePath = getStorePath(lockfile, name)
		local updated, count = config:gsub(`(%f[%w]{alias}%s*=%s*")[^"]*(")`, `%1{storePath}%2`)
		assert(count == 1, `Expected one "{alias}" alias in {CONFIG_PATH}, found {count}`)
		config = updated
	end

	fs.writeStringToFile(CONFIG_PATH, config)
	print(`wrote dependency aliases to {CONFIG_PATH}`)
end

local function installWallyPackages()
	run({ "wally", "install" })
	run({ "rojo", "sourcemap", project.ROJO_BUILD_PROJECT, "-o", "sourcemap.json" })
	run({ "wally-package-types", "--sourcemap", "sourcemap.json", "Packages" })
end

installLoomPackages()
installWallyPackages()
