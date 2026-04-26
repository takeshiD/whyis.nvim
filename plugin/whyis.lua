vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function(args)
		local bufnr = args.buf
		if not require("whyis.config").current.prefetch then
			return
		end
		local ft = vim.bo[bufnr].filetype
		if ft ~= "typescript" and ft ~= "javascript" then
			return
		end
		if not require("whyis.utils").is_deno(bufnr) then
			return
		end
		require("whyis.linter.denols").prefetch(bufnr)
	end,
	desc = "Whyis: background prefetch for HTTP-based linters",
})

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
