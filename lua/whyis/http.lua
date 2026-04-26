local M = {}

---@param url string
---@param timeout_ms? integer default:500
---@return string? content
---@return string? err
function M.fetch(url, timeout_ms)
	timeout_ms = timeout_ms or 1000
	-- neovim 0.12 or newer
	if vim.net ~= nil then
		local content = nil
		local err = nil
		local done = false
		vim.net.request(url, {}, function(e, r)
			if err ~= nil then
				err = e
			else
				content = r.body
                done = true
			end
		end)
		vim.wait(timeout_ms, function()
			return done
		end, 200)
		return content, err
	end
	-- older than 0.12
	if vim.fn.executable("curl") == 0 then
		return nil, "curl is not found in your PATH"
	end
	local result = vim.system({ "curl", "-s", "--fail", "-L", url }, { text = true, timeout = timeout_ms }):wait()
	if result.code ~= 0 then
		return nil, "internet connection failed"
	end
	return result.stdout, nil
end

return M
