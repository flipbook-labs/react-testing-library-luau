--!nonstrict
local JestGlobals = require("@pkg/JestGlobals")

local prettyInstanceTree = require("./prettyInstanceTree")
local within = require("./within")

local afterEach = JestGlobals.afterEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local container: Folder

afterEach(function()
	if container then
		container:Destroy()
	end
end)

describe("within", function()
	it("scopes queries to the given container", function()
		container = Instance.new("Folder")

		local inner = Instance.new("Frame")
		inner.Parent = container

		local insideLabel = Instance.new("TextLabel")
		insideLabel.Text = "Inside"
		insideLabel.Parent = inner

		local outsideLabel = Instance.new("TextLabel")
		outsideLabel.Text = "Outside"
		outsideLabel.Parent = container

		local queries = within(inner)

		expect(queries.getByText("Inside")).toBe(insideLabel)
		expect(queries.queryByText("Outside")).toBeNil()
	end)
end)

describe("prettyInstanceTree", function()
	it("renders the tree with text details", function()
		container = Instance.new("Folder")
		container.Name = "Root"

		local label = Instance.new("TextLabel")
		label.Name = "Greeting"
		label.Text = "Hello"
		label.Parent = container

		local rendered = prettyInstanceTree(container)

		expect(rendered).toContain('Folder "Root"')
		expect(rendered).toContain('TextLabel "Greeting"')
		expect(rendered).toContain('Text="Hello"')
	end)

	it("marks the highlighted instance", function()
		container = Instance.new("Folder")
		local label = Instance.new("TextLabel")
		label.Text = "Target"
		label.Parent = container

		local rendered = prettyInstanceTree(container, { highlight = label })

		expect(rendered).toContain("◄")
	end)

	it("truncates below maxDepth", function()
		container = Instance.new("Folder")
		local current: Instance = container
		for index = 1, 4 do
			local child = Instance.new("Frame")
			child.Name = `Level{index}`
			child.Parent = current
			current = child
		end

		local rendered = prettyInstanceTree(container, { maxDepth = 2 })

		expect(rendered).toContain("Level1")
		expect(rendered).toContain("Level2")
		expect(rendered).toContain("...")
		expect(rendered).never.toContain("Level3")
	end)
end)

return nil
