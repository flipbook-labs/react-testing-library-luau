-- All paths are relative to the root of the repo

return {
	-- Workspace packages live in modules/ (NOT packages/) because Wally installs
	-- into Packages/, and on a case-insensitive filesystem (macOS default) that
	-- is the same directory — `wally install` would clobber the sources.
	PACKAGES = {
		{
			name = "InstanceTesting",
			sourcePath = "modules/instance-testing/src",
			buildPath = "dist/InstanceTesting",
		},
		{
			name = "ReactTesting",
			sourcePath = "modules/react-testing/src",
			buildPath = "dist/ReactTesting",
		},
	},

	BUILD_PATH = "dist",
	PACKAGES_PATH = "Packages",
	LUTE_SCRIPTS_PATH = ".lute",

	FOLDERS_TO_LINT = { "modules", ".lute" },

	MODEL_FILENAME = "ReactTestingLibraryLuau.rbxm",

	SOURCEMAP_PATH = "sourcemap.json",
	DARKLUA_SOURCEMAP_PATH = "sourcemap-darklua.json",

	ROJO_BUILD_PROJECT = "build.project.json",
	ROJO_TESTS_PROJECT = "tests.project.json",
	ROJO_DEFAULT_PROJECT = "default.project.json",

	ROBLOX_UNIT_TESTING_PLACE_ID = "123506190725771",
	ROBLOX_UNIT_TESTING_UNIVERSE_ID = "6599100156",
}
