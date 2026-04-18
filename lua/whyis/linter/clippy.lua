local utils = require("whyis.utils")

---@param bufnr integer
---@param lnum  integer
---@return boolean
local function enabled(bufnr, lnum)
	return utils.is_rust(bufnr) and utils.contain_diagnostic(bufnr, lnum, "clippy")
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
			or string.format("[whyis:ERROR] cargo clippy --explain failed with exit code %d", result.code)
		return nil, err
	end
	return result.stdout, nil
end

---@param vim.Diagnotic
---@return string? lint_code
local function extract_lintcode(diagnotic)
	return diagnotic.user_data.lsp.code
end

---@param bufnr number
---@param lnum number
---@return table<LinterRule, WhyisContent>
local function execute(bufnr, lnum)
	local diagnotics = vim.diagnostic.get(bufnr, { lnum = lnum - 1 })
	---@type table<LinterRule, WhyisContent>
	local contents = {}
	for _, diag in ipairs(diagnotics) do
		if diag.source == "clippy" then
			local lint_code = extract_lintcode(diag)
			if lint_code ~= nil then
				local explain, err = clippy_explain(lint_code)
				if err ~= nil then
					vim.notify(err)
				end
				local whyis_content = {
					source = diag.source,
					lint_code = diag.code,
					explain = explain,
				}
				contents[diag.code] = whyis_content
			end
		end
	end
	return contents
end

return {
	enabled = enabled,
	execute = execute,
}
