local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")

local ReactTesting = require("@self")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

ReactTesting.installCleanup(JestGlobals.afterEach)

local render = ReactTesting.render
local fireEvent = ReactTesting.fireEvent

describe("render", function()
	test("renders into a fresh ScreenGui by default", function()
		local result = render(React.createElement("TextLabel", {
			Text = "Hello",
		}))

		expect(result.container.ClassName).toBe("ScreenGui")
		expect(result.getByText("Hello")).toBeDefined()
	end)

	test("renders into a provided container and does not destroy it on unmount", function()
		local container: Instance = Instance.new("Folder")
		local result = render(
			React.createElement("TextLabel", {
				Text = "Hello",
			}),
			{ container = container }
		)

		expect(result.container).toBe(container)
		expect(result.getByText("Hello")).toBeDefined()

		result.unmount()
		expect(container.Parent).toBeNil()
		expect(#container:GetChildren()).toBe(0)
		container:Destroy()
	end)

	test("rerenders in place", function()
		local function Greeting(props)
			return React.createElement("TextLabel", {
				Text = `Hello, {props.name}!`,
			})
		end

		local result = render(React.createElement(Greeting, { name = "Marin" }))
		expect(result.getByText("Hello, Marin!")).toBeDefined()

		result.rerender(React.createElement(Greeting, { name = "World" }))
		expect(result.queryByText("Hello, Marin!")).toBeNil()
		expect(result.getByText("Hello, World!")).toBeDefined()
	end)

	test("unmounts and empties the container", function()
		local result = render(React.createElement("TextLabel", {
			Text = "Short-lived",
		}))
		local container = result.container

		result.unmount()

		expect(container.Parent).toBeNil()
	end)
end)

describe("acceptance: counter", function()
	test("renders, clicks, and observes the state change", function()
		local function Counter()
			local count, setCount = React.useState(0)
			return React.createElement("Frame", {
				Size = UDim2.fromOffset(200, 100),
			}, {
				Label = React.createElement("TextLabel", {
					Text = `Count: {count}`,
					LayoutOrder = 1,
				}),
				Increment = React.createElement("TextButton", {
					Text = "Increment",
					LayoutOrder = 2,
					[React.Event.Activated] = function()
						setCount(function(current)
							return current + 1
						end)
					end,
				}),
			})
		end

		local result = render(React.createElement(Counter))

		expect(result.getByText("Count: 0")).toBeDefined()

		fireEvent.activated(result.getByText("Increment") :: TextButton)

		ReactTesting.waitFor(function()
			expect(result.getByText("Count: 1")).toBeDefined()
		end)

		fireEvent.activated(result.getByText("Increment") :: TextButton)
		ReactTesting.waitFor(function()
			expect(result.getByText("Count: 2")).toBeDefined()
		end)
	end)
end)

return nil
