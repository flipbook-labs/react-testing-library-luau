--!strict

-- Internal: turns a `queryAll` primitive into the four synchronous query
-- variants with consistent error behavior:
--
--   queryAll  -> { Instance }        (possibly empty)
--   query     -> Instance?           (errors if more than one match)
--   getAll    -> { Instance }        (errors if empty)
--   get       -> Instance            (errors if empty or more than one match)
--
-- The async find/findAll variants live in the react-testing package, built on
-- waitFor.

local prettyInstanceTree = require("./prettyInstanceTree")

export type Variants<M, O> = {
	queryAll: (container: Instance, matcher: M, options: O?) -> { Instance },
	query: (container: Instance, matcher: M, options: O?) -> Instance?,
	getAll: (container: Instance, matcher: M, options: O?) -> { Instance },
	get: (container: Instance, matcher: M, options: O?) -> Instance,
}

type Describe<M> = (matcher: M) -> string

local function queryError(message: string, container: Instance): string
	return `{message}\n\nContainer:\n{prettyInstanceTree(container)}`
end

local function buildVariants<M, O>(
	queryAll: (container: Instance, matcher: M, options: O?) -> { Instance },
	queryName: string,
	describeMatcher: Describe<M>
): Variants<M, O>
	local function query(container: Instance, matcher: M, options: O?): Instance?
		local matched = queryAll(container, matcher, options)
		if #matched > 1 then
			error(
				queryError(
					`Found {#matched} elements matching {queryName}({describeMatcher(matcher)}) when at most one was expected.`
						.. ` If this is intentional, use the All variant (e.g. queryAll/getAll).`,
					container
				),
				0
			)
		end
		return matched[1]
	end

	local function getAll(container: Instance, matcher: M, options: O?): { Instance }
		local matched = queryAll(container, matcher, options)
		if #matched == 0 then
			error(
				queryError(`Unable to find an element matching {queryName}({describeMatcher(matcher)}).`, container),
				0
			)
		end
		return matched
	end

	local function get(container: Instance, matcher: M, options: O?): Instance
		local matched = getAll(container, matcher, options)
		if #matched > 1 then
			error(
				queryError(
					`Found {#matched} elements matching {queryName}({describeMatcher(matcher)}) when exactly one was expected.`
						.. ` If this is intentional, use the All variant (e.g. queryAll/getAll).`,
					container
				),
				0
			)
		end
		return matched[1]
	end

	return {
		queryAll = queryAll,
		query = query,
		getAll = getAll,
		get = get,
	}
end

local function collectDescendants(container: Instance, predicate: (Instance) -> boolean): { Instance }
	local matched: { Instance } = {}
	for _, descendant in container:GetDescendants() do
		if predicate(descendant) then
			table.insert(matched, descendant)
		end
	end
	return matched
end

return {
	buildVariants = buildVariants,
	collectDescendants = collectDescendants,
	queryError = queryError,
}
