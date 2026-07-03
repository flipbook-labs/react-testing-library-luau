--!strict

-- ReactTesting: render / fireEvent / act / waitFor for react-lua components,
-- with instance queries re-exported from InstanceTesting.

local InstanceTesting = require("@instancetesting")

local actImpl = require("@self/act")
local cleanupModule = require("@self/cleanup")
local find = require("@self/queries/find")
local fireEvent = require("@self/fireEvent")
local renderImpl = require("@self/render")
local waitForImpl = require("@self/waitFor")

export type TextMatch = InstanceTesting.TextMatch
export type TextMatchOptions = InstanceTesting.TextMatchOptions
export type BoundQueries = InstanceTesting.BoundQueries
export type RenderOptions = renderImpl.RenderOptions
export type RenderResult = renderImpl.RenderResult
export type WaitForOptions = waitForImpl.WaitForOptions

return {
	render = renderImpl,
	cleanup = cleanupModule.cleanup,
	installCleanup = cleanupModule.installCleanup,
	act = actImpl,
	fireEvent = fireEvent,
	waitFor = waitForImpl,

	-- Query surfaces from the instance-testing layer.
	within = InstanceTesting.within,
	prettyInstanceTree = InstanceTesting.prettyInstanceTree,
	configure = InstanceTesting.configure,

	getByText = InstanceTesting.getByText,
	getAllByText = InstanceTesting.getAllByText,
	queryByText = InstanceTesting.queryByText,
	queryAllByText = InstanceTesting.queryAllByText,

	getByPlaceholderText = InstanceTesting.getByPlaceholderText,
	getAllByPlaceholderText = InstanceTesting.getAllByPlaceholderText,
	queryByPlaceholderText = InstanceTesting.queryByPlaceholderText,
	queryAllByPlaceholderText = InstanceTesting.queryAllByPlaceholderText,

	getByDisplayValue = InstanceTesting.getByDisplayValue,
	getAllByDisplayValue = InstanceTesting.getAllByDisplayValue,
	queryByDisplayValue = InstanceTesting.queryByDisplayValue,
	queryAllByDisplayValue = InstanceTesting.queryAllByDisplayValue,

	getByTestId = InstanceTesting.getByTestId,
	getAllByTestId = InstanceTesting.getAllByTestId,
	queryByTestId = InstanceTesting.queryByTestId,
	queryAllByTestId = InstanceTesting.queryAllByTestId,

	findByText = find.findByText,
	findAllByText = find.findAllByText,
	findByPlaceholderText = find.findByPlaceholderText,
	findAllByPlaceholderText = find.findAllByPlaceholderText,
	findByDisplayValue = find.findByDisplayValue,
	findAllByDisplayValue = find.findAllByDisplayValue,
	findByTestId = find.findByTestId,
	findAllByTestId = find.findAllByTestId,
}
