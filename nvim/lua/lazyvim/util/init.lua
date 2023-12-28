local LazyUtil = require("lazy.core.util")

---@class lazyvim.util: LazyUtilCore
---@field lsp lazyvim.util.lsp
---@field root lazyvim.util.root
---@field telescope lazyvim.util.telescope
---@field plugin lazyvim.util.plugin
---@field lualine lazyvim.util.lualine
---@field ui lazyvim.util.ui
local M = {}

setmetatable(M, {
	__index = function(t, k)
		if LazyUtil[k] then
			return LazyUtil[k]
		end
		t[k] = require("lazyvim.util." .. k)
		return t[k]
	end,
})

return M
