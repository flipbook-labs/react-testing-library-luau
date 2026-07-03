--!nonstrict
local CollectionService = game:GetService("CollectionService")

local JestGlobals = require("@pkg/JestGlobals")

local configure = require("../configure")
local testId = require("./testId")

local afterEach = JestGlobals.afterEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local container: Folder

local function makeTagged(id: string, name: string?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name or "Frame"
	frame.Parent = container
	CollectionService:AddTag(frame, `data-testid={id}`)
	return frame
end

local function newContainer()
	container = Instance.new("Folder")
end

afterEach(function()
	if container then
		container:Destroy()
	end
	configure.configure({ testIdAttribute = "data-testid" })
end)

describe("getByTestId", function()
	it("finds an instance tagged data-testid=<value>", function()
		newContainer()
		local frame = makeTagged("submit-button")

		expect(testId.get(container, "submit-button")).toBe(frame)
	end)

	it("does not match other test ids", function()
		newContainer()
		makeTagged("other")

		expect(testId.query(container, "submit-button")).toBeNil()
	end)

	it("does not match unrelated tags", function()
		newContainer()
		local frame = Instance.new("Frame")
		frame.Parent = container
		CollectionService:AddTag(frame, "some-other-tag")

		expect(testId.query(container, "some-other-tag")).toBeNil()
	end)

	it("throws when nothing matches", function()
		newContainer()
		expect(function()
			testId.get(container, "missing")
		end).toThrow("Unable to find an element matching ByTestId")
	end)

	it("returns all matches through getAll", function()
		newContainer()
		local first = makeTagged("row", "First")
		local second = makeTagged("row", "Second")

		expect(testId.getAll(container, "row")).toEqual({ first, second })
	end)

	it("errors when one instance carries two test ids", function()
		newContainer()
		local frame = makeTagged("one")
		CollectionService:AddTag(frame, "data-testid=two")

		expect(function()
			testId.get(container, "one")
		end).toThrow("multiple")
	end)
end)

describe("configure", function()
	it("respects a custom testIdAttribute", function()
		newContainer()
		configure.configure({ testIdAttribute = "my-id" })

		local frame = Instance.new("Frame")
		frame.Parent = container
		CollectionService:AddTag(frame, "my-id=special")

		expect(testId.get(container, "special")).toBe(frame)
	end)
end)

return nil
