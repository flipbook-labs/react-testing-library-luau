local JestGlobals = require("@pkg/JestGlobals")

local displayValue = require("./displayValue")
local placeholderText = require("./placeholderText")

local afterEach = JestGlobals.afterEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local container: Folder

local function makeTextBox(value: string, placeholder: string): TextBox
	local box = Instance.new("TextBox")
	box.Text = value
	box.PlaceholderText = placeholder
	box.Parent = container
	return box
end

local function newContainer()
	container = Instance.new("Folder")
end

afterEach(function()
	if container then
		container:Destroy()
	end
end)

describe("getByPlaceholderText", function()
	it("finds a TextBox by placeholder", function()
		newContainer()
		local box = makeTextBox("", "Username")

		expect(placeholderText.get(container, "Username")).toBe(box)
	end)

	it("ignores TextLabels", function()
		newContainer()
		local label = Instance.new("TextLabel")
		label.Text = "Username"
		label.Parent = container

		expect(placeholderText.query(container, "Username")).toBeNil()
	end)

	it("supports substring matching", function()
		newContainer()
		local box = makeTextBox("", "Enter your username")

		expect(placeholderText.get(container, "username", { exact = false })).toBe(box)
	end)
end)

describe("getByDisplayValue", function()
	it("finds a TextBox by its current value", function()
		newContainer()
		local box = makeTextBox("marin", "Username")

		expect(displayValue.get(container, "marin")).toBe(box)
	end)

	it("returns nil for a value no TextBox holds", function()
		newContainer()
		makeTextBox("marin", "Username")

		expect(displayValue.query(container, "someone-else")).toBeNil()
	end)
end)

return nil
