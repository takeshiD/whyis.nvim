---@meta

---@class WhyisContent
---@field source string
---@field lint_code string
---@field explain string

---@alias LinterRule string

---@class WhyisLinter
---@field enabled fun(bufnr: integer, lnum: integer): boolean
---@field execute fun(bufnr: integer, lnum: integer): table<LinterRule, WhyisContent>
---@field prefetch? fun(bufnr: integer): nil
