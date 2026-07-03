--!strict

-- Queries TextBoxes by their PlaceholderText.

local matching = require("../matching")
local queryEngine = require("../queryEngine")
local types = require("../types")

type TextMatch = types.TextMatch
type TextMatchOptions = types.TextMatchOptions

local function queryAllByPlaceholderText(
	container: Instance,
	matcher: TextMatch,
	options: TextMatchOptions?
): { Instance }
	return queryEngine.collectDescendants(container, function(descendant)
		return descendant:IsA("TextBox") and matching.matches(descendant.PlaceholderText, descendant, matcher, options)
	end)
end

local function describeMatcher(matcher: TextMatch): string
	return if typeof(matcher) == "string" then `"{matcher}"` else "<function matcher>"
end

return queryEngine.buildVariants(queryAllByPlaceholderText, "ByPlaceholderText", describeMatcher)
