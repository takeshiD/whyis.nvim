local ruff = require("whyis.linter.ruff")
local async = require("hover.async")

---@param bufnr integer
---@param opts? Hover.Options
---@return boolean
local function enabled(bufnr, opts)
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	return ruff.enabled(bufnr, lnum)
end

---@param params Hover.Provider.Params
---@param done fun(result?: false|Hover.Provider.Result)
local function execute(params, done)
	async.run(function()
		local bufnr = params.bufnr
		local lnum = params.pos[1]
		local explain = ruff.execute(bufnr, lnum)
		if explain ~= nil then
			local lines = {}
			for _, line in ipairs(vim.split(explain, "\n")) do
				lines[#lines + 1] = line
			end
			done({ lines = lines, filetype = "markdown" })
		else
			done({ lines = {}, filetype = "markdown" })
		end
	end)
end

---@return Hover.Provider
return {
	name = "Whyis",
	priority = 1000,
	enabled = enabled,
	execute = execute,
}
