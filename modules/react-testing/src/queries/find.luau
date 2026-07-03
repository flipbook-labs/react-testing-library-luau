--!strict

-- Async query variants: poll (via waitFor) until the underlying get/getAll
-- succeeds or the timeout elapses. Useful for UI that appears after effects
-- or deferred state updates.

local InstanceTesting = require("@instancetesting")

local waitFor = require("../waitFor")

type TextMatch = InstanceTesting.TextMatch
type TextMatchOptions = InstanceTesting.TextMatchOptions
type WaitForOptions = waitFor.WaitForOptions

type TextGetter = (container: Instance, matcher: TextMatch, options: TextMatchOptions?) -> Instance
type TextAllGetter = (container: Instance, matcher: TextMatch, options: TextMatchOptions?) -> { Instance }

local function makeFind(getter: TextGetter)
	return function(
		container: Instance,
		matcher: TextMatch,
		options: TextMatchOptions?,
		waitForOptions: WaitForOptions?
	): Instance
		local found: Instance
		waitFor(function()
			found = getter(container, matcher, options)
		end, waitForOptions)
		return found
	end
end

local function makeFindAll(getter: TextAllGetter)
	return function(
		container: Instance,
		matcher: TextMatch,
		options: TextMatchOptions?,
		waitForOptions: WaitForOptions?
	): { Instance }
		local found: { Instance }
		waitFor(function()
			found = getter(container, matcher, options)
		end, waitForOptions)
		return found
	end
end

local findByText = makeFind(InstanceTesting.getByText)
local findAllByText = makeFindAll(InstanceTesting.getAllByText)
local findByPlaceholderText = makeFind(InstanceTesting.getByPlaceholderText)
local findAllByPlaceholderText = makeFindAll(InstanceTesting.getAllByPlaceholderText)
local findByDisplayValue = makeFind(InstanceTesting.getByDisplayValue)
local findAllByDisplayValue = makeFindAll(InstanceTesting.getAllByDisplayValue)

local function findByTestId(container: Instance, testId: string, waitForOptions: WaitForOptions?): Instance
	local found: Instance
	waitFor(function()
		found = InstanceTesting.getByTestId(container, testId, nil)
	end, waitForOptions)
	return found
end

local function findAllByTestId(container: Instance, testId: string, waitForOptions: WaitForOptions?): { Instance }
	local found: { Instance }
	waitFor(function()
		found = InstanceTesting.getAllByTestId(container, testId, nil)
	end, waitForOptions)
	return found
end

export type BoundFindQueries = {
	findByText: (matcher: TextMatch, options: TextMatchOptions?, waitForOptions: WaitForOptions?) -> Instance,
	findAllByText: (matcher: TextMatch, options: TextMatchOptions?, waitForOptions: WaitForOptions?) -> { Instance },
	findByPlaceholderText: (
		matcher: TextMatch,
		options: TextMatchOptions?,
		waitForOptions: WaitForOptions?
	) -> Instance,
	findAllByPlaceholderText: (
		matcher: TextMatch,
		options: TextMatchOptions?,
		waitForOptions: WaitForOptions?
	) -> { Instance },
	findByDisplayValue: (matcher: TextMatch, options: TextMatchOptions?, waitForOptions: WaitForOptions?) -> Instance,
	findAllByDisplayValue: (
		matcher: TextMatch,
		options: TextMatchOptions?,
		waitForOptions: WaitForOptions?
	) -> { Instance },
	findByTestId: (testId: string, waitForOptions: WaitForOptions?) -> Instance,
	findAllByTestId: (testId: string, waitForOptions: WaitForOptions?) -> { Instance },
}

local function within(container: Instance): BoundFindQueries
	return {
		findByText = function(matcher: TextMatch, options: TextMatchOptions?, waitForOptions: WaitForOptions?)
			return findByText(container, matcher, options, waitForOptions)
		end,
		findAllByText = function(matcher: TextMatch, options: TextMatchOptions?, waitForOptions: WaitForOptions?)
			return findAllByText(container, matcher, options, waitForOptions)
		end,
		findByPlaceholderText = function(
			matcher: TextMatch,
			options: TextMatchOptions?,
			waitForOptions: WaitForOptions?
		)
			return findByPlaceholderText(container, matcher, options, waitForOptions)
		end,
		findAllByPlaceholderText = function(
			matcher: TextMatch,
			options: TextMatchOptions?,
			waitForOptions: WaitForOptions?
		)
			return findAllByPlaceholderText(container, matcher, options, waitForOptions)
		end,
		findByDisplayValue = function(matcher: TextMatch, options: TextMatchOptions?, waitForOptions: WaitForOptions?)
			return findByDisplayValue(container, matcher, options, waitForOptions)
		end,
		findAllByDisplayValue = function(
			matcher: TextMatch,
			options: TextMatchOptions?,
			waitForOptions: WaitForOptions?
		)
			return findAllByDisplayValue(container, matcher, options, waitForOptions)
		end,
		findByTestId = function(testId: string, waitForOptions: WaitForOptions?)
			return findByTestId(container, testId, waitForOptions)
		end,
		findAllByTestId = function(testId: string, waitForOptions: WaitForOptions?)
			return findAllByTestId(container, testId, waitForOptions)
		end,
	}
end

return {
	findByText = findByText,
	findAllByText = findAllByText,
	findByPlaceholderText = findByPlaceholderText,
	findAllByPlaceholderText = findAllByPlaceholderText,
	findByDisplayValue = findByDisplayValue,
	findAllByDisplayValue = findAllByDisplayValue,
	findByTestId = findByTestId,
	findAllByTestId = findAllByTestId,
	within = within,
}
