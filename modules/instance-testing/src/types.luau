--!strict

--- A text matcher: either a literal string or a predicate over the normalized
--- text and the instance it came from.
export type TextMatch = string | (text: string, instance: Instance) -> boolean

--- Options accepted by every text-driven query.
---
--- `exact` (default `true`): the normalized text must equal the matcher.
--- When `false`, a case-insensitive substring match is used instead.
--- `pattern` (default `false`): treat a string matcher as a Lua pattern
--- (mutually exclusive with `exact = false`).
--- `normalizer`: replaces the default whitespace normalization (trim +
--- collapse runs of whitespace). Applied before matching.
export type TextMatchOptions = {
	exact: boolean?,
	pattern: boolean?,
	normalizer: ((text: string) -> string)?,
}

return {}
