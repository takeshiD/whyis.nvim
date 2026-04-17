vim.api.nvim_create_user_command("WhyisOpen", function(opts)
	local view = require("whyis.view")
	view.open({
		mode = opts.fargs[1],
        bufnr = vim.api.nvim_get_current_buf(),
        lnum = vim.api.nvim_win_get_cursor(0)[1],
	})
end, {
	nargs = "?",
	complete = function(arglead, cmdline, cursorpos)
		return { "left", "right", "top", "bottom", "float" }
	end,
})
