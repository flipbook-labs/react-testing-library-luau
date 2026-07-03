-- Queries TextBoxes by their current (user-editable) Text value.

local matching = require("../matching")
local queryEngine = require("../queryEngine")
local types = require("../types")

type TextMatch = types.TextMatch
type TextMatchOptions = types.TextMatchOptions

local function queryAllByDisplayValue(container: Instance, matcher: TextMatch, options: TextMatchOptions?): { Instance }
	return queryEngine.collectDescendants(container, function(descendant)
		return descendant:IsA("TextBox") and matching.matches(descendant.Text, descendant, matcher, options)
	end)
end

local function describeMatcher(matcher: TextMatch): string
	return if typeof(matcher) == "string" then `"{matcher}"` else "<function matcher>"
end

return queryEngine.buildVariants(queryAllByDisplayValue, "ByDisplayValue", describeMatcher)
