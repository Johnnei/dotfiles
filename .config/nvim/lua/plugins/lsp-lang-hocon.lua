-- Remap probable hocon conf files to Hocon

local hocon_group = vim.api.nvim_create_augroup("hocon", { clear = true })
vim.api.nvim_create_autocmd(
	{ 'BufNewFile', 'BufRead' },
	{ group = hocon_group, pattern = '*/resources/*.conf', command = 'set ft=hocon' }
)

--[[

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
configs.hocon_ls = {
	default_config = {
		cmd = { '/home/johnnei/git/hocon-rs/target/debug/hocon-ls' },
		filetypes = { "conf" },
		root_dir = function(fname)
			return vim.fn.getcwd()
		end,
	},
}
-- lspconfig.hocon_ls.setup{}
--]]

return {
	-- Add Hocon to teesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "hocon" })
		end,
	},
	--[[{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				honcon_ls = {
				},
			},
		},
	},]]
}
