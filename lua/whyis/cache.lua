local M = {}

local cache_root = vim.fn.stdpath("cache") .. "/whyis/"

---@param namespace string
---@param key string
---@param ttl_days? integer default 30
---@return string? content
function M.get(namespace, key, ttl_days)
	ttl_days = ttl_days or 30
	local dir = cache_root .. namespace .. "/" .. key .. "/"
	local pattern = dir .. "*_" .. key .. ".md"
	local files = vim.fn.glob(pattern, false, true)
	if #files == 0 then
		return nil
	end
	table.sort(files)
	local file = files[#files]
	local basename = vim.fn.fnamemodify(file, ":t")
	local date_str = basename:match("^(%d%d%d%d%d%d%d%d)_")
	if not date_str then
		return nil
	end
	local year = tonumber(date_str:sub(1, 4)) or 0
	local month = tonumber(date_str:sub(5, 6)) or 0
	local day = tonumber(date_str:sub(7, 8)) or 0
	local cache_time = os.time({ year = year, month = month, day = day, hour = 0, min = 0, sec = 0 })
	local age_days = (os.time() - cache_time) / 86400
	if age_days > ttl_days then
		return nil
	end
	local lines = vim.fn.readfile(file)
	return table.concat(lines, "\n")
end

---@param namespace string
---@param key string
---@param content string
function M.set(namespace, key, content)
	local dir = cache_root .. namespace .. "/" .. key .. "/"
	vim.fn.mkdir(dir, "p")
	local date = os.date("%Y%m%d")
	local filepath = dir .. date .. "_" .. key .. ".md"
	vim.fn.writefile(vim.split(content, "\n"), filepath)
end

return M
