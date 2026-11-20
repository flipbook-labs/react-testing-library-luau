-- The package's own aliases. This file ships with the package (see `files` in
-- `pkg.luau`), unlike the repo-root `.config.luau`, whose aliases point at
-- folders in this repo's checkout. Dependency aliases, like `@pkg` for the
-- Wally packages, aren't defined here, so a consumer's config supplies them.
return {
	luau = {
		aliases = {
			instancetesting = "./instance-testing/src",
		},
	},
}
