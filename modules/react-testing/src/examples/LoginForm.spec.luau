--!nonstrict
-- Dogfood spec: exercises the whole public API against a realistic component.
-- If this file is awkward to write, the library is wrong — treat friction
-- here as API feedback, not something to work around.

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")

local ReactTesting = require("@reacttesting")

local LoginForm = require("./LoginForm")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local jest = JestGlobals.jest

ReactTesting.installCleanup(JestGlobals.afterEach)

local render = ReactTesting.render
local fireEvent = ReactTesting.fireEvent

local function renderForm()
	local onSubmit, onSubmitFn = jest.fn()
	local result = render(React.createElement(LoginForm, {
		onSubmit = onSubmitFn,
	}))
	return result, onSubmit
end

describe("LoginForm", function()
	it("submits valid credentials", function()
		local result, onSubmit = renderForm()

		fireEvent.textChanged(result.getByPlaceholderText("Username") :: TextBox, "marin")
		fireEvent.textChanged(result.getByPlaceholderText("Password") :: TextBox, "hunter2hunter2")
		fireEvent.activated(result.getByText("Log in") :: TextButton)

		expect(onSubmit).toHaveBeenCalledTimes(1)
		expect(onSubmit).toHaveBeenCalledWith("marin", "hunter2hunter2")
		expect(result.queryByTestId("login-error")).toBeNil()
	end)

	it("requires a username", function()
		local result, onSubmit = renderForm()

		fireEvent.activated(result.getByText("Log in") :: TextButton)

		expect(onSubmit).never.toHaveBeenCalled()
		expect(result.getByText("Username is required")).toBe(result.getByTestId("login-error"))
	end)

	it("rejects short passwords, then clears the error on success", function()
		local result, onSubmit = renderForm()

		fireEvent.textChanged(result.getByPlaceholderText("Username") :: TextBox, "marin")
		fireEvent.textChanged(result.getByPlaceholderText("Password") :: TextBox, "short")
		fireEvent.activated(result.getByText("Log in") :: TextButton)

		expect(onSubmit).never.toHaveBeenCalled()
		expect(result.getByText("Password must be", { exact = false })).toBeDefined()

		fireEvent.textChanged(result.getByPlaceholderText("Password") :: TextBox, "long-enough-now")
		fireEvent.activated(result.getByText("Log in") :: TextButton)

		expect(onSubmit).toHaveBeenCalledTimes(1)
		expect(result.queryByTestId("login-error")).toBeNil()
	end)

	it("reflects typed text in the display value", function()
		local result = renderForm()

		fireEvent.textChanged(result.getByPlaceholderText("Username") :: TextBox, "typed")

		ReactTesting.waitFor(function()
			expect(result.getByDisplayValue("typed")).toBeDefined()
		end)
	end)
end)

return nil
