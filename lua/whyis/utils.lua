local M = {}
---@param bufnr integer
---@return boolean
function M.is_rust(bufnr)
	return vim.bo[bufnr].filetype == "rust"
end

---@param bufnr integer
---@return boolean
function M.is_python(bufnr)
	return vim.bo[bufnr].filetype == "python"
end

---@param bufnr integer
---@return boolean
function M.is_ts(bufnr)
	local ft = vim.bo[bufnr].filetype
	return ft == "typescript" or ft == "javascript"
end

---@param bufnr integer
---@param lnum integer
---@param lsp_name string
---@return boolean
function M.contain_diagnostic(bufnr, lnum, lsp_name)
	local diagnotics = vim.diagnostic.get(bufnr, { lnum = lnum - 1 })
	for _, diag in ipairs(diagnotics) do
		if diag.source == lsp_name then
			return true
		end
	end
	return false
end

---@param bufnr integer
---@return boolean
function M.is_deno(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "denols" })
	return #clients > 0
end

return M
