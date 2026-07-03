-- Binds every query to a container, giving the ergonomic form used in tests:
--
--   local queries = within(container)
--   queries.getByText("Log in")
--
-- render() in the react-testing package spreads these onto its result.

local displayValue = require("./queries/displayValue")
local placeholderText = require("./queries/placeholderText")
local testId = require("./queries/testId")
local text = require("./queries/text")
local types = require("./types")

type TextMatch = types.TextMatch
type TextMatchOptions = types.TextMatchOptions

export type BoundQueries = {
	getByText: (matcher: TextMatch, options: TextMatchOptions?) -> Instance,
	getAllByText: (matcher: TextMatch, options: TextMatchOptions?) -> { Instance },
	queryByText: (matcher: TextMatch, options: TextMatchOptions?) -> Instance?,
	queryAllByText: (matcher: TextMatch, options: TextMatchOptions?) -> { Instance },

	getByPlaceholderText: (matcher: TextMatch, options: TextMatchOptions?) -> Instance,
	getAllByPlaceholderText: (matcher: TextMatch, options: TextMatchOptions?) -> { Instance },
	queryByPlaceholderText: (matcher: TextMatch, options: TextMatchOptions?) -> Instance?,
	queryAllByPlaceholderText: (matcher: TextMatch, options: TextMatchOptions?) -> { Instance },

	getByDisplayValue: (matcher: TextMatch, options: TextMatchOptions?) -> Instance,
	getAllByDisplayValue: (matcher: TextMatch, options: TextMatchOptions?) -> { Instance },
	queryByDisplayValue: (matcher: TextMatch, options: TextMatchOptions?) -> Instance?,
	queryAllByDisplayValue: (matcher: TextMatch, options: TextMatchOptions?) -> { Instance },

	getByTestId: (testId: string) -> Instance,
	getAllByTestId: (testId: string) -> { Instance },
	queryByTestId: (testId: string) -> Instance?,
	queryAllByTestId: (testId: string) -> { Instance },
}

local function within(container: Instance): BoundQueries
	return {
		getByText = function(matcher: TextMatch, options: TextMatchOptions?)
			return text.get(container, matcher, options)
		end,
		getAllByText = function(matcher: TextMatch, options: TextMatchOptions?)
			return text.getAll(container, matcher, options)
		end,
		queryByText = function(matcher: TextMatch, options: TextMatchOptions?)
			return text.query(container, matcher, options)
		end,
		queryAllByText = function(matcher: TextMatch, options: TextMatchOptions?)
			return text.queryAll(container, matcher, options)
		end,

		getByPlaceholderText = function(matcher: TextMatch, options: TextMatchOptions?)
			return placeholderText.get(container, matcher, options)
		end,
		getAllByPlaceholderText = function(matcher: TextMatch, options: TextMatchOptions?)
			return placeholderText.getAll(container, matcher, options)
		end,
		queryByPlaceholderText = function(matcher: TextMatch, options: TextMatchOptions?)
			return placeholderText.query(container, matcher, options)
		end,
		queryAllByPlaceholderText = function(matcher: TextMatch, options: TextMatchOptions?)
			return placeholderText.queryAll(container, matcher, options)
		end,

		getByDisplayValue = function(matcher: TextMatch, options: TextMatchOptions?)
			return displayValue.get(container, matcher, options)
		end,
		getAllByDisplayValue = function(matcher: TextMatch, options: TextMatchOptions?)
			return displayValue.getAll(container, matcher, options)
		end,
		queryByDisplayValue = function(matcher: TextMatch, options: TextMatchOptions?)
			return displayValue.query(container, matcher, options)
		end,
		queryAllByDisplayValue = function(matcher: TextMatch, options: TextMatchOptions?)
			return displayValue.queryAll(container, matcher, options)
		end,

		getByTestId = function(id: string)
			return testId.get(container, id, nil)
		end,
		getAllByTestId = function(id: string)
			return testId.getAll(container, id, nil)
		end,
		queryByTestId = function(id: string)
			return testId.query(container, id, nil)
		end,
		queryAllByTestId = function(id: string)
			return testId.queryAll(container, id, nil)
		end,
	}
end

return within
