local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")

local ReactTesting = require("@self")
local waitFor = require("./waitFor")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

ReactTesting.installCleanup(JestGlobals.afterEach)

describe("waitFor", function()
	it("returns as soon as the callback stops throwing", function()
		local attempts = 0
		waitFor(function()
			attempts += 1
			if attempts < 3 then
				error("not yet")
			end
		end)
		expect(attempts).toBe(3)
	end)

	it("throws the last error after the timeout", function()
		expect(function()
			waitFor(function()
				error("never succeeds")
			end, { timeout = 0.1, interval = 0.02 })
		end).toThrow("never succeeds")
	end)
end)

describe("findBy queries", function()
	it("finds elements that appear after an effect", function()
		local function AppearsLater()
			local visible, setVisible = React.useState(false)

			React.useEffect(function()
				task.delay(0.1, function()
					setVisible(true)
				end)
			end, {})

			return if visible
				then React.createElement("TextLabel", { Text = "Loaded" })
				else React.createElement("TextLabel", { Text = "Loading..." })
		end

		local result = ReactTesting.render(React.createElement(AppearsLater))

		expect(result.getByText("Loading...")).toBeDefined()

		local loaded = result.findByText("Loaded", nil, { timeout = 2 })
		expect(loaded).toBeDefined()
	end)

	it("findByTestId times out with the query error", function()
		local result = ReactTesting.render(React.createElement("Frame"))

		expect(function()
			result.findByTestId("never-appears", { timeout = 0.1, interval = 0.02 })
		end).toThrow("Unable to find an element matching ByTestId")
	end)
end)

return nil
