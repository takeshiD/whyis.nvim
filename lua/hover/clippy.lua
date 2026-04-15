local clippy = require("whyis.linter.clippy")
local async = require("hover.async")

---@param bufnr integer
---@param opts? Hover.Options
---@return boolean
local function enabled(bufnr, opts)
	return clippy.enabled(bufnr, opts)
end

---@param params Hover.Provider.Params
---@param done fun(result?: false|Hover.Provider.Result)
local function execute(params, done)
	async.run(function()
		local bufnr = params.bufnr
		local lnum = params.pos[1]
		local explain = clippy.execute(bufnr, lnum)
		local lines = {}
		for _, line in ipairs(vim.split(explain, "\n")) do
			lines[#lines + 1] = line
		end
		done({ lines = lines, filetype = "markdown" })
	end)
end

---@return Hover.Provider
return {
	name = "whyis.clippy",
	enabled = enabled,
	exucute = execute,
}
