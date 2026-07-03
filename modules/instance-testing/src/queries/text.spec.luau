local JestGlobals = require("@pkg/JestGlobals")

local text = require("./text")

local afterEach = JestGlobals.afterEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local container: Folder

local function makeLabel(labelText: string, name: string?): TextLabel
	local label = Instance.new("TextLabel")
	label.Text = labelText
	label.Name = name or "TextLabel"
	label.Parent = container
	return label
end

local function newContainer()
	container = Instance.new("Folder")
end

afterEach(function()
	if container then
		container:Destroy()
	end
end)

describe("getByText", function()
	it("finds a TextLabel by exact text", function()
		newContainer()
		local label = makeLabel("Log in")

		expect(text.get(container, "Log in")).toBe(label)
	end)

	it("finds a TextButton by exact text", function()
		newContainer()
		local button = Instance.new("TextButton")
		button.Text = "Submit"
		button.Parent = container

		expect(text.get(container, "Submit")).toBe(button)
	end)

	it("normalizes whitespace by default", function()
		newContainer()
		local label = makeLabel("  Log   in  ")

		expect(text.get(container, "Log in")).toBe(label)
	end)

	it("does not match TextBoxes", function()
		newContainer()
		local box = Instance.new("TextBox")
		box.Text = "typed value"
		box.Parent = container

		expect(text.query(container, "typed value")).toBeNil()
	end)

	it("throws with the container tree when nothing matches", function()
		newContainer()
		makeLabel("Something else")

		expect(function()
			text.get(container, "Log in")
		end).toThrow("Unable to find an element matching ByText")
	end)

	it("throws when multiple elements match", function()
		newContainer()
		makeLabel("Duplicate")
		makeLabel("Duplicate")

		expect(function()
			text.get(container, "Duplicate")
		end).toThrow("Found 2 elements")
	end)

	it("searches nested containers", function()
		newContainer()
		local frame = Instance.new("Frame")
		frame.Parent = container
		local label = Instance.new("TextLabel")
		label.Text = "Nested"
		label.Parent = frame

		expect(text.get(container, "Nested")).toBe(label)
	end)
end)

describe("query/queryAll/getAll variants", function()
	it("queryByText returns nil when nothing matches", function()
		newContainer()
		expect(text.query(container, "missing")).toBeNil()
	end)

	it("queryByText throws when multiple elements match", function()
		newContainer()
		makeLabel("Duplicate")
		makeLabel("Duplicate")

		expect(function()
			text.query(container, "Duplicate")
		end).toThrow("Found 2 elements")
	end)

	it("queryAllByText returns an empty table when nothing matches", function()
		newContainer()
		expect(text.queryAll(container, "missing")).toEqual({})
	end)

	it("getAllByText returns every match", function()
		newContainer()
		local first = makeLabel("Duplicate", "First")
		local second = makeLabel("Duplicate", "Second")

		expect(text.getAll(container, "Duplicate")).toEqual({ first, second })
	end)

	it("getAllByText throws when nothing matches", function()
		newContainer()
		expect(function()
			text.getAll(container, "missing")
		end).toThrow("Unable to find an element")
	end)
end)

describe("matcher options", function()
	it("exact = false does case-insensitive substring matching", function()
		newContainer()
		local label = makeLabel("Welcome back, Marin!")

		expect(text.get(container, "welcome back", { exact = false })).toBe(label)
	end)

	it("pattern = true treats the matcher as a Lua pattern", function()
		newContainer()
		local label = makeLabel("Count: 42")

		expect(text.get(container, "^Count: %d+$", { pattern = true })).toBe(label)
	end)

	it("accepts a function matcher receiving normalized text and instance", function()
		newContainer()
		local label = makeLabel("target")

		local found = text.get(container, function(normalized, instance)
			return normalized == "target" and instance:IsA("TextLabel")
		end)

		expect(found).toBe(label)
	end)

	it("supports a custom normalizer", function()
		newContainer()
		local label = makeLabel("MONEY")

		local found = text.get(container, "money", {
			normalizer = function(value)
				return string.lower(value)
			end,
		})

		expect(found).toBe(label)
	end)
end)

return nil
