-- Example component used by the dogfood specs (and the README-style docs).
-- A small but realistic form: two TextBoxes, client-side validation, and a
-- submit button that reports the credentials upward.

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

export type Props = {
	onSubmit: (username: string, password: string) -> (),
}

local function LoginForm(props: Props)
	local username, setUsername = React.useState("")
	local password, setPassword = React.useState("")
	local error_, setError = React.useState("")

	local function submit()
		if username == "" then
			setError("Username is required")
			return
		end
		if #password < 8 then
			setError("Password must be at least 8 characters")
			return
		end
		setError("")
		props.onSubmit(username, password)
	end

	return React.createElement("Frame", {
		Size = UDim2.fromOffset(320, 240),
	}, {
		Username = React.createElement("TextBox", {
			PlaceholderText = "Username",
			Text = username,
			LayoutOrder = 1,
			[React.Change.Text] = function(rbx: TextBox)
				setUsername(rbx.Text)
			end,
		}),
		Password = React.createElement("TextBox", {
			PlaceholderText = "Password",
			Text = password,
			LayoutOrder = 2,
			[React.Change.Text] = function(rbx: TextBox)
				setPassword(rbx.Text)
			end,
		}),
		ErrorMessage = if error_ ~= ""
			then React.createElement("TextLabel", {
				Text = error_,
				LayoutOrder = 3,
				[ReactRoblox.Tag] = "data-testid=login-error",
			})
			else nil,
		Submit = React.createElement("TextButton", {
			Text = "Log in",
			LayoutOrder = 4,
			[React.Event.Activated] = submit,
		}),
	})
end

return LoginForm
