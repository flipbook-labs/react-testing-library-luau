--!strict

-- Renders a React element into a container and returns the container-bound
-- queries plus lifecycle controls.

local InstanceTesting = require("@instancetesting")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local find = require("./queries/find")
local mountedRoots = require("./mountedRoots")
local waitFor = require("./waitFor")

local act = ReactRoblox.act

type TextMatch = InstanceTesting.TextMatch
type TextMatchOptions = InstanceTesting.TextMatchOptions
type WaitForOptions = waitFor.WaitForOptions

export type RenderOptions = {
	--- Render into this instance instead of a fresh ScreenGui. The caller owns
	--- the container's lifetime; render() will not destroy it.
	container: Instance?,
}

export type BoundFindQueries = find.BoundFindQueries

export type RenderResult = InstanceTesting.BoundQueries & BoundFindQueries & {
	container: Instance,
	unmount: () -> (),
	rerender: (element: React.Node) -> (),
}

local function render(element: React.Node, options: RenderOptions?): RenderResult
	local providedContainer = if options ~= nil then options.container else nil
	local ownsContainer = providedContainer == nil

	local container: Instance
	if providedContainer ~= nil then
		container = providedContainer
	else
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ReactTestingContainer"
		-- A real GUI tree makes focus and layout behave; CoreGui is writable
		-- in both cloud test sessions and Studio. Fine if it fails — queries
		-- and fireEvent do not require a parented container.
		pcall(function()
			screenGui.Parent = game:GetService("CoreGui")
		end)
		container = screenGui
	end

	local root = ReactRoblox.createRoot(container)
	mountedRoots.register({
		root = root,
		container = container,
		ownsContainer = ownsContainer,
	})

	act(function()
		root:render(element)
	end)

	local queries = InstanceTesting.within(container)
	local findQueries = find.within(container)

	local function unmount()
		mountedRoots.unregister(root)
		act(function()
			root:unmount()
		end)
		if ownsContainer then
			container:Destroy()
		end
	end

	local function rerender(nextElement: React.Node)
		act(function()
			root:render(nextElement)
		end)
	end

	return {
		container = container,
		unmount = unmount,
		rerender = rerender,

		getByText = queries.getByText,
		getAllByText = queries.getAllByText,
		queryByText = queries.queryByText,
		queryAllByText = queries.queryAllByText,

		getByPlaceholderText = queries.getByPlaceholderText,
		getAllByPlaceholderText = queries.getAllByPlaceholderText,
		queryByPlaceholderText = queries.queryByPlaceholderText,
		queryAllByPlaceholderText = queries.queryAllByPlaceholderText,

		getByDisplayValue = queries.getByDisplayValue,
		getAllByDisplayValue = queries.getAllByDisplayValue,
		queryByDisplayValue = queries.queryByDisplayValue,
		queryAllByDisplayValue = queries.queryAllByDisplayValue,

		getByTestId = queries.getByTestId,
		getAllByTestId = queries.getAllByTestId,
		queryByTestId = queries.queryByTestId,
		queryAllByTestId = queries.queryAllByTestId,

		findByText = findQueries.findByText,
		findAllByText = findQueries.findAllByText,
		findByPlaceholderText = findQueries.findByPlaceholderText,
		findAllByPlaceholderText = findQueries.findAllByPlaceholderText,
		findByDisplayValue = findQueries.findByDisplayValue,
		findAllByDisplayValue = findQueries.findAllByDisplayValue,
		findByTestId = findQueries.findByTestId,
		findAllByTestId = findQueries.findAllByTestId,
	}
end

return render
