return {
	luau = {
		languagemode = "strict",
		aliases = {
			lute = "~/.lute/typedefs/1.0.1/lute",
			std = "~/.lute/typedefs/1.0.1/std",
			pkg = "./Packages",
			instancetesting = "./modules/instance-testing/src",
			reacttesting = "./modules/react-testing/src",
			repo = ".",

			-- `lute run install` copies these from the Loom store.
			-- https://github.com/flipbook-labs/flipbook/issues/689 tracks removing this vendoring.
			batteries = "./LuauPackages/Batteries",
			["flipbook-batteries"] = "./LuauPackages/FlipbookBatteries",
		},
	},
}
