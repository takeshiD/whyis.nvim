---@param bufnr integer
---@return boolean
local function enabled(bufnr)
	local ft = vim.bo[bufnr].filetype
	return ft == "rust"
end

---@param lint_code string
---@param opts? {cwd?: string, timeout?: number}
---@return string? stdout
---@return string? err
local function clippy_explain(lint_code, opts)
	opts = opts or {}
	local cmd = {
		"cargo",
		"clippy",
		"--explain",
		string.format("clippy::%s", lint_code),
	}
	local result = vim.system(cmd, {
		trext = true,
		cwd = opts.cwd,
	}):wait(opts.timeout)
	if result.code ~= 0 then
		local err = result.stderr ~= "" and result.stderr
			or string.format("cargo clippy --explain failed with exit code %d")
		return nil, err
	end
	return result.stderr, nil
end

---@param vim.Diagnotic
---@return string? lint_code
local function extract_lintcode(diagnotic)
	return diagnotic.code
end

---@param bufnr number
---@param lnum number
---@return string? explain
local function execute(bufnr, lnum)
	local diagnotics = vim.diagnostic.get(bufnr, { lnum = lnum })
	for _, diag in ipairs(diagnotics) do
		local lint_code = extract_lintcode(diag)
		local explain, err = clippy_explain(lint_code)
		if err ~= nil then
			vim.notify(err)
		end
		return explain
	end
end

return {
	enabled = enabled,
	execute = execute,
}
