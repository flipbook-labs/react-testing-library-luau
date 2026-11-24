return {
	bump = "patch",
	category = "Internal",
	kind = "tooling",
	summary = "Library source no longer carries per-file `--!strict` directives.",
	body = "Strict typechecking is enforced repo-wide via `.luaurc`, and the spec files (previously `--!nonstrict`) are now strict-checked too.",
}
