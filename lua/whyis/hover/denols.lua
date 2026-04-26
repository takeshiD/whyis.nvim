local denols = require("whyis.linter.denols")
local async = require("hover.async")

---@param bufnr integer
---@param opts? Hover.Options
---@return boolean
local function enabled(bufnr, opts)
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	return denols.enabled(bufnr, lnum)
end

---@param params Hover.Provider.Params
---@param done fun(result?: false|Hover.Provider.Result)
local function execute(params, done)
	async.run(function()
		local bufnr = params.bufnr
		local lnum = params.pos[1]
		---@type table<LinterRule, WhyisContent>
		local contents = denols.execute(bufnr, lnum)
		local is_first = true
		local lines = {}
		for _, content in pairs(contents) do
			if not is_first then
				lines[#lines + 1] = "-------"
			end
			is_first = false
			local header = string.format("# %s(%s)", content.lint_code, content.source)
			lines[#lines + 1] = header
			lines[#lines + 1] = content.explain
		end
		if #lines == 0 then
			lines = { "no result" }
		end
		done({ lines = lines, filetype = "markdown" })
	end)
end

---@return Hover.Provider
return {
	name = "denols",
	priority = 1000,
	enabled = enabled,
	execute = execute,
}
