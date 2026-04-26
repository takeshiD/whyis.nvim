local utils = require("whyis.utils")
local http = require("whyis.http")
local cache = require("whyis.cache")

local BASE_URL = "https://docs.deno.com/lint/rules/%s.md"
local CACHE_NS = "deno-lint"
local CACHE_TTL = 30

---@param bufnr integer
---@param lnum integer 1-indexed line number
---@return boolean
local function enabled(bufnr, lnum)
	return utils.is_deno(bufnr) and utils.contain_diagnostic(bufnr, lnum, "deno-lint")
end

---@param lint_code string
---@return string? content
---@return string? err
local function fetch_rule(lint_code)
	local cached = cache.get(CACHE_NS, lint_code, CACHE_TTL)
	if cached then
		return cached, nil
	end
	local url = string.format(BASE_URL, lint_code)
	local content, err = http.fetch(url)
	if err or content == nil then
		return nil, err
	end
	cache.set(CACHE_NS, lint_code, content)
	return content, nil
end

---@param bufnr number
---@param lnum number 1-indexed line number
---@return table<LinterRule, WhyisContent>
local function execute(bufnr, lnum)
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum - 1 })
	---@type table<LinterRule, WhyisContent>
	local contents = {}
	for _, diag in ipairs(diagnostics) do
		if diag.source == "deno-lint" then
			local lint_code = diag.code
			if lint_code ~= nil then
				local explain, err = fetch_rule(lint_code)
				if err ~= nil then
					vim.notify(err)
				end
				contents[lint_code] = {
					source = diag.source,
					lint_code = tostring(lint_code),
					explain = explain or "",
				}
			end
		end
	end
	return contents
end

return {
	enabled = enabled,
	execute = execute,
}
