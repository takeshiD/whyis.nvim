local M = {}

---@class WhyisLinter
---@field enabled fun(bufnr: integer, lnum: integer): boolean
---@field execute fun(bufnr: integer, lnum: integer): table<LinterRule, WhyisContent>

---@param bufnr integer
---@return WhyisLinter[]
local function get_linters(bufnr)
	local ft = vim.bo[bufnr].filetype
	if ft == "rust" then
		return {
			require("whyis.linter.clippy"),
			require("whyis.linter.bacon_ls"),
		}
	elseif ft == "python" then
		return { require("whyis.linter.ruff") }
	elseif ft == "typescript" or ft == "javascript" then
		return { require("whyis.linter.biome") }
	end
	return {}
end

---@param contents table<LinterRule, WhyisContent>
---@return string[]
local function contents_to_lines(contents)
	local is_first = true
	local lines = {}
	for _, content in pairs(contents) do
		if not is_first then
			lines[#lines + 1] = "-------"
		end
		is_first = false
		lines[#lines + 1] = string.format("# %s(%s)", content.lint_code, content.source)
		for _, line in ipairs(vim.split(content.explain or "", "\n")) do
			lines[#lines + 1] = line
		end
	end
	return lines
end

---@param bufnr integer
---@param lnum integer
---@return string[]?
local function collect_lines(bufnr, lnum)
	local linters = get_linters(bufnr)
	if #linters == 0 then
		vim.notify("[whyis] unsupported filetype: " .. vim.bo[bufnr].filetype, vim.log.levels.WARN)
		return nil
	end

	local any_enabled = false
	for _, linter in ipairs(linters) do
		if linter.enabled(bufnr, lnum) then
			any_enabled = true
			break
		end
	end
	if not any_enabled then
		vim.notify("[whyis] linter not available for this buffer", vim.log.levels.WARN)
		return nil
	end

	local all_lines = {}
	for _, linter in ipairs(linters) do
		if linter.enabled(bufnr, lnum) then
			local contents = linter.execute(bufnr, lnum)
			if not vim.tbl_isempty(contents) then
				if #all_lines > 0 then
					all_lines[#all_lines + 1] = "---"
				end
				for _, line in ipairs(contents_to_lines(contents)) do
					all_lines[#all_lines + 1] = line
				end
			end
		end
	end

	if #all_lines == 0 then
		vim.notify("[whyis] no explains at cursor", vim.log.levels.INFO)
		return nil
	end
	return all_lines
end

---@param lines string[]
---@return integer bufnr
local function make_scratch_buf(lines)
	local sbuf = vim.api.nvim_create_buf(false, true)
	vim.bo[sbuf].filetype = "markdown"
	vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, lines)
	vim.bo[sbuf].modifiable = false
	return sbuf
end

--- Open explain in a split scratch buffer.
---@param bufnr? integer defaults to current buffer
---@param lnum? integer defaults to cursor line
---@param mode? "top"|"bottom"|"left"|"right" defaults to "bottom"
function M.open_scratch(bufnr, lnum, mode)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]

	local split_cmds = {
		top = "topleft split",
		bottom = "botright split",
		left = "topleft vsplit",
		right = "botright vsplit",
	}

	local lines = collect_lines(bufnr, lnum)
	if not lines then
		return
	end

	local sbuf = make_scratch_buf(lines)
	vim.cmd(split_cmds[mode] or split_cmds.bottom)
	vim.api.nvim_win_set_buf(0, sbuf)
end

--- Open explain in a centred floating window.
---@param bufnr? integer defaults to current buffer
---@param lnum? integer defaults to cursor line
function M.open_float(bufnr, lnum)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]

	local lines = collect_lines(bufnr, lnum)
	if not lines then
		return
	end

	local fbuf = make_scratch_buf(lines)

	local max_line_len = 0
	for _, line in ipairs(lines) do
		if #line > max_line_len then
			max_line_len = #line
		end
	end

	local width = math.min(math.max(max_line_len, 40), math.floor(vim.o.columns * 0.85))
	local height = math.min(#lines, math.floor(vim.o.lines * 0.75))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(fbuf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Whyis ",
		title_pos = "center",
	})

	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true

	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = fbuf, silent = true, nowait = true })
	end

	return win
end

--- Open explain using the given mode.
---@param opts? {mode?: "left"|"right"|"top"|"bottom"|"float", bufnr?: integer, lnum?: integer}
function M.open(opts)
	opts = opts or {}
	local mode = opts.mode or "float"
	if mode ~= "float" then
		M.open_scratch(opts.bufnr, opts.lnum, mode)
	else
		M.open_float(opts.bufnr, opts.lnum)
	end
end

return M
