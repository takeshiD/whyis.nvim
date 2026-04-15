# hover-clippy-why.nvim

A [hover.nvim](https://github.com/lewis6991/hover.nvim) provider that shows the clippy explain.

Powered by `cargo clippy`, it lets you quickly understand code is *What is bad?*.

## Requirements

- Neovim 0.10+
- [hover.nvim](https://github.com/lewis6991/hover.nvim)
- cargo
- clippy

## Installation

### lazy.nvim

```lua
{
	"lewis6991/hover.nvim",
	dependencies = {
		"takeshid/hover-clippy-why.nvim",
	},
	config = function()
		vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
		require("hover").config({
			providers = {
				"hover.providers.diagnostic",
				"hover.providers.lsp",
				"hover.providers.gh",
				"hover-clippy-why", -- add this line to your config
			},
			preview_opts = { border = "single" },
			preview_window = true,
			title = true,
		})
	end,
}
```

# License
MIT
