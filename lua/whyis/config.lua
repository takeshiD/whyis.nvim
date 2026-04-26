local M = {}

---@class WhyisConfig
---@field prefetch boolean

---@type WhyisConfig
M.defaults = {
	prefetch = true,
}

---@type WhyisConfig
M.current = vim.deepcopy(M.defaults)

---@param opts? WhyisConfig
function M.setup(opts)
	M.current = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
