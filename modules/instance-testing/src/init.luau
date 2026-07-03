-- InstanceTesting: queries over Roblox Instances — the folded
-- dom-testing-library layer. No React dependency; usable against any
-- Instance tree (React, Roact, Fusion, or hand-built).

local configure = require("@self/configure")
local displayValue = require("@self/queries/displayValue")
local placeholderText = require("@self/queries/placeholderText")
local prettyInstanceTree = require("@self/prettyInstanceTree")
local testId = require("@self/queries/testId")
local text = require("@self/queries/text")
local types = require("@self/types")
local within = require("@self/within")

export type TextMatch = types.TextMatch
export type TextMatchOptions = types.TextMatchOptions
export type BoundQueries = within.BoundQueries
export type PrettyOptions = prettyInstanceTree.PrettyOptions
export type ConfigOverrides = configure.ConfigOverrides

return {
	within = within,
	prettyInstanceTree = prettyInstanceTree,
	configure = configure.configure,
	getConfig = configure.getConfig,

	-- Container-first query forms, for use without within()/render().
	getByText = text.get,
	getAllByText = text.getAll,
	queryByText = text.query,
	queryAllByText = text.queryAll,

	getByPlaceholderText = placeholderText.get,
	getAllByPlaceholderText = placeholderText.getAll,
	queryByPlaceholderText = placeholderText.query,
	queryAllByPlaceholderText = placeholderText.queryAll,

	getByDisplayValue = displayValue.get,
	getAllByDisplayValue = displayValue.getAll,
	queryByDisplayValue = displayValue.query,
	queryAllByDisplayValue = displayValue.queryAll,

	getByTestId = testId.get,
	getAllByTestId = testId.getAll,
	queryByTestId = testId.query,
	queryAllByTestId = testId.queryAll,
	getTestId = testId.getTestId,
}
