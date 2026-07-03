-- Queries by displayed text: the `Text` property of TextLabels and
-- TextButtons. TextBoxes are excluded — their `Text` is a user-editable
-- value, queried via displayValue instead (mirrors upstream testing-library,
-- where getByText ignores inputs).

local matching = require("../matching")
local queryEngine = require("../queryEngine")
local types = require("../types")

type TextMatch = types.TextMatch
type TextMatchOptions = types.TextMatchOptions

local function getDisplayedText(instance: Instance): string?
	if instance:IsA("TextLabel") then
		return instance.Text
	end
	if instance:IsA("TextButton") then
		return instance.Text
	end
	return nil
end

local function queryAllByText(container: Instance, matcher: TextMatch, options: TextMatchOptions?): { Instance }
	return queryEngine.collectDescendants(container, function(descendant)
		local text = getDisplayedText(descendant)
		return text ~= nil and matching.matches(text, descendant, matcher, options)
	end)
end

local function describeMatcher(matcher: TextMatch): string
	return if typeof(matcher) == "string" then `"{matcher}"` else "<function matcher>"
end

return queryEngine.buildVariants(queryAllByText, "ByText", describeMatcher)
