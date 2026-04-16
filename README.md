# whyis.nvim

A Neovim plugin that explains LSP diagnostics from linters — *Why is bad?*

Supports displaying explanations via [hover.nvim](https://github.com/lewis6991/hover.nvim) or in a scratch buffer.

# Requirements

- Neovim 0.10+
- Your linter(s) of choice (clippy, ruff, ...)
- [hover.nvim](https://github.com/lewis6991/hover.nvim) *(optional — required only for hover integration)*

# Supported Linters

| Linter                                             | Language   | Command used                            |
| --------                                           | ---------- | --------------                          |
| [clippy](https://github.com/rust-lang/rust-clippy) | Rust       | `cargo clippy --explain clippy::<code>` |
| [ruff](https://github.com/astral-sh/ruff)          | Python     | `ruff rule --output-format text <code>` |


# Installation

## lazy.nvim

### With hover.nvim

```lua
{
	"lewis6991/hover.nvim",
	dependencies = {
		"takeshid/whyis.nvim",
	},
	config = function()
		vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
		require("hover").config({
			providers = {
				"hover.providers.diagnostic",
				"hover.providers.lsp",
				"whyis.hover.clippy", -- Rust / clippy
				"whyis.hover.ruff",   -- Python / ruff
			},
			preview_opts = { border = "single" },
			preview_window = true,
			title = true,
		})
	end,
}
```

### Scratch buffer (without hover.nvim)

```lua
{
	"takeshid/whyis.nvim",
	config = function()
		vim.keymap.set("n", "<leader>wk", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local lnum = vim.api.nvim_win_get_cursor(0)[1]

			-- choose the linter module that fits the current buffer
			local ft = vim.bo[bufnr].filetype
			local linter
			if ft == "rust" then
				linter = require("whyis.linter.clippy")
			elseif ft == "python" then
				linter = require("whyis.linter.ruff")
			end

			if not linter or not linter.enabled(bufnr, lnum) then
				return
			end

			local explain = linter.execute(bufnr, lnum)
			if not explain then
				return
			end

			-- open a scratch buffer
			local sbuf = vim.api.nvim_create_buf(false, true)
			vim.bo[sbuf].filetype = "markdown"
			vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, vim.split(explain, "\n"))
			vim.cmd("split")
			vim.api.nvim_win_set_buf(0, sbuf)
		end, { desc = "whyis: explain diagnostic" })
	end,
}
```

# License

MIT
