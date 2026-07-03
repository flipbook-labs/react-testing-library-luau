-- Renders an Instance subtree as an indented text tree for query error
-- messages, the way prettyDOM does for HTML. Shows the details queries care
-- about: displayed text, placeholder, and test-id tags.

local CollectionService = game:GetService("CollectionService")

local configure = require("./configure")

local DEFAULT_MAX_DEPTH = 6

export type PrettyOptions = {
	maxDepth: number?,
	--- Instance to mark with `◄` in the output (e.g. a match being reported).
	highlight: Instance?,
}

local function describeInstance(instance: Instance): string
	local details = {}

	if instance:IsA("TextLabel") or instance:IsA("TextButton") then
		table.insert(details, `Text="{instance.Text}"`)
	elseif instance:IsA("TextBox") then
		table.insert(details, `Text="{instance.Text}"`)
		table.insert(details, `PlaceholderText="{instance.PlaceholderText}"`)
	end

	local testIdPrefix = configure.getConfig().testIdAttribute .. "="
	for _, tag in CollectionService:GetTags(instance) do
		if string.sub(tag, 1, #testIdPrefix) == testIdPrefix then
			table.insert(details, tag)
		end
	end

	local suffix = if #details > 0 then ` ({table.concat(details, ", ")})` else ""
	return `{instance.ClassName} "{instance.Name}"{suffix}`
end

local function prettyInstanceTree(root: Instance, options: PrettyOptions?): string
	local maxDepth = if options ~= nil and options.maxDepth ~= nil then options.maxDepth else DEFAULT_MAX_DEPTH
	local highlight = if options ~= nil then options.highlight else nil

	local lines: { string } = {}

	local function visit(instance: Instance, depth: number)
		local indent = string.rep("    ", depth)
		local marker = if instance == highlight then "  ◄" else ""
		table.insert(lines, `{indent}{describeInstance(instance)}{marker}`)

		if depth >= maxDepth then
			if #instance:GetChildren() > 0 then
				table.insert(lines, `{indent}    ...`)
			end
			return
		end

		for _, child in instance:GetChildren() do
			visit(child, depth + 1)
		end
	end

	visit(root, 0)

	return table.concat(lines, "\n")
end

return prettyInstanceTree
