local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")

local ReactTesting = require("@self")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

ReactTesting.installCleanup(JestGlobals.afterEach)

local render = ReactTesting.render
local fireEvent = ReactTesting.fireEvent

describe("fireEvent.activated", function()
	it("invokes the Activated handler", function()
		local clicks = 0
		local result = render(React.createElement("TextButton", {
			Text = "Click",
			[React.Event.Activated] = function()
				clicks += 1
			end,
		}))

		fireEvent.activated(result.getByText("Click") :: TextButton)
		fireEvent.activated(result.getByText("Click") :: TextButton)

		expect(clicks).toBe(2)
	end)

	it("is a no-op when no handler is registered", function()
		local result = render(React.createElement("TextButton", {
			Text = "Inert",
		}))

		expect(function()
			fireEvent.activated(result.getByText("Inert") :: TextButton)
		end).never.toThrow()
	end)
end)

describe("fireEvent.mouse*", function()
	it("invokes MouseButton1Click, MouseEnter, and MouseLeave handlers", function()
		local events: { string } = {}
		local result = render(React.createElement("TextButton", {
			Text = "Hover",
			[React.Event.MouseButton1Click] = function()
				table.insert(events, "click")
			end,
			[React.Event.MouseEnter] = function()
				table.insert(events, "enter")
			end,
			[React.Event.MouseLeave] = function()
				table.insert(events, "leave")
			end,
		}))

		local button = result.getByText("Hover") :: TextButton
		fireEvent.mouseEnter(button)
		fireEvent.mouseButton1Click(button)
		fireEvent.mouseLeave(button)

		expect(events).toEqual({ "enter", "click", "leave" })
	end)
end)

describe("fireEvent.textChanged", function()
	it("sets the text and fires the Change.Text handler for real", function()
		local observed: { string } = {}
		local result = render(React.createElement("TextBox", {
			Text = "",
			PlaceholderText = "Type here",
			[React.Change.Text] = function(rbx: TextBox)
				table.insert(observed, rbx.Text)
			end,
		}))

		local box = result.getByPlaceholderText("Type here") :: TextBox
		fireEvent.textChanged(box, "hello")

		expect(observed).toEqual({ "hello" })
		expect(result.getByDisplayValue("hello")).toBe(box)
	end)

	it("drives controlled TextBoxes through React state", function()
		local function Controlled()
			local value, setValue = React.useState("")
			return React.createElement("TextBox", {
				Text = value,
				PlaceholderText = "Controlled",
				[React.Change.Text] = function(rbx: TextBox)
					setValue(rbx.Text)
				end,
			})
		end

		local result = render(React.createElement(Controlled))
		local box = result.getByPlaceholderText("Controlled") :: TextBox

		fireEvent.textChanged(box, "typed")

		ReactTesting.waitFor(function()
			expect(result.getByDisplayValue("typed")).toBeDefined()
		end)
	end)
end)

describe("fireEvent.focus / blur", function()
	it("fires Focused and FocusLost handlers exactly once each", function()
		local focusCount = 0
		local blurCount = 0

		local result = render(React.createElement("TextBox", {
			Text = "",
			PlaceholderText = "Focusable",
			[React.Event.Focused] = function()
				focusCount += 1
			end,
			[React.Event.FocusLost] = function()
				blurCount += 1
			end,
		}))

		local box = result.getByPlaceholderText("Focusable") :: TextBox

		fireEvent.focus(box)
		expect(focusCount).toBe(1)
		expect(blurCount).toBe(0)

		fireEvent.blur(box)
		expect(focusCount).toBe(1)
		expect(blurCount).toBe(1)
	end)
end)

describe("fireEvent.custom", function()
	it("fires arbitrary event props by key and reports whether a handler ran", function()
		local received: { unknown } = {}
		local result = render(React.createElement("TextButton", {
			Text = "Custom",
			[React.Event.MouseButton1Down] = function(_rbx, x, y)
				table.insert(received, x)
				table.insert(received, y)
			end,
		}))

		local button = result.getByText("Custom") :: TextButton

		local ran = fireEvent.custom(button, React.Event.MouseButton1Down, 10, 20)
		expect(ran).toBe(true)
		expect(received).toEqual({ 10, 20 })

		local ranMissing = fireEvent.custom(button, React.Event.MouseButton2Down)
		expect(ranMissing).toBe(false)
	end)
end)

return nil
