# whyis.nvim

A Neovim plugin that explains LSP diagnostics from linters — *Why is bad?*

Supports displaying explanations in a floating window or scratch buffer, via [hover.nvim](https://github.com/lewis6991/hover.nvim).

- Example `clippy`

<img src="assets/clippy.gif" width="600" />

- Example `ruff`

<img src="assets/ruff.gif" width="600" />

# Requirements

- Neovim 0.10+
- Your linter(s) of choice (clippy, ruff, biome, denols, ...)
- [hover.nvim](https://github.com/lewis6991/hover.nvim) *(optional — required only for hover integration)*
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) *(optional)*
- `curl` *(required for deno-lint — used to fetch rule docs from docs.deno.com)*

# Supported Linters

| Linter                                             | Language              | Doc source                  |
| --------                                           | ----------            | ----------                  |
| [clippy](https://github.com/rust-lang/rust-clippy) | Rust                  | bundled in LSP message      |
| [bacon-ls](https://github.com/crisidev/bacon-ls)   | Rust                  | bundled in LSP message      |
| [ruff](https://github.com/astral-sh/ruff)          | Python                | `ruff rule <code>`          |
| [biome](https://github.com/biomejs/biome)          | TypeScript/JavaScript | `biome explain <code>`      |
| [deno-lint](https://docs.deno.com/lint/rules/)     | TypeScript/JavaScript | fetched from docs.deno.com  |

> [!NOTE]
> **deno-lint** requires [denols](https://github.com/denoland/vscode_deno) to be active in the buffer.
> Rule docs are fetched from `https://docs.deno.com/lint/rules/<code>.md` and cached locally under
> `stdpath("cache")/whyis/deno-lint/` for 30 days (configurable).
> On Neovim 0.12+ `vim.net.request()` is used; older versions fall back to `curl`.

# Installation

## lazy.nvim

### Scratch buffer / Floating window (without hover.nvim)

You can use `WhyisOpen [win_opt]` command as follows.

```lua
{
  "takeshid/whyis.nvim",
  event = "VeryLazy",
  keys = {
    {"<leader>wf", "<cmd>WhyisOpen float<cr>",   desc = "Whyis floating window"},
    {"<leader>wl", "<cmd>WhyisOpen right<cr>",   desc = "Whyis right side"},
  }
}
```

Inside the floating window press `q` or `<Esc>` to close it.

Available window options: `float` (default), `top`, `bottom`, `left`, `right`.

### With hover.nvim

<img src="assets/clippy_hover.gif" width="800" />

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
        "whyis.hover",  -- add to your configuration
      },
      preview_opts = { border = "single" },
      preview_window = true,
      title = true,
    })
  end,
}
```

# Configuration

Call `require("whyis.config").setup()` with your overrides. All fields are optional.

```lua
require("whyis.config").setup({
  -- Prefetch rule docs in the background when diagnostics change.
  -- Applies to linters that fetch docs over HTTP (currently: deno-lint).
  -- Set to false if you prefer on-demand fetching.
  prefetch = true,  -- default: true
})
```

### `prefetch`

When `true`, whyis listens to `DiagnosticChanged` and asynchronously fetches and caches rule docs
for all diagnostics in the buffer before you open a hover or scratch window.
This avoids any visible delay when you actually invoke the explain UI.

# License

MIT
