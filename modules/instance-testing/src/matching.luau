--!strict

-- Text matching shared by every query. Behavior mirrors upstream
-- testing-library's matches/fuzzyMatches, expressed with Luau string
-- facilities (Lua patterns via `pattern = true` instead of RegExp).

local types = require("./types")

type TextMatch = types.TextMatch
type TextMatchOptions = types.TextMatchOptions

local function defaultNormalizer(text: string): string
	local trimmed = string.match(text, "^%s*(.-)%s*$") or text
	local collapsed = string.gsub(trimmed, "%s+", " ")
	return collapsed
end

local function getNormalizer(options: TextMatchOptions?): (string) -> string
	if options ~= nil and options.normalizer ~= nil then
		return options.normalizer
	end
	return defaultNormalizer
end

local function matches(rawText: string, instance: Instance, matcher: TextMatch, options: TextMatchOptions?): boolean
	local normalize = getNormalizer(options)
	local normalized = normalize(rawText)

	if typeof(matcher) == "function" then
		return matcher(normalized, instance)
	end

	local exact = if options ~= nil and options.exact ~= nil then options.exact else true
	local pattern = if options ~= nil and options.pattern ~= nil then options.pattern else false

	if pattern then
		return string.match(normalized, matcher) ~= nil
	end

	if exact then
		return normalized == matcher
	end

	return string.find(string.lower(normalized), string.lower(matcher), 1, true) ~= nil
end

return {
	defaultNormalizer = defaultNormalizer,
	matches = matches,
}
