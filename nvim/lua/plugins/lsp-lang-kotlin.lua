local kotlinls_group = vim.api.nvim_create_augroup("kotlinls", { clear = true })
vim.api.nvim_create_autocmd(
	{ 'BufNewFile', 'BufRead' },
	{ group = kotlinls_group, pattern = { "*.kt", "*.kts" }, command = 'set ft=kotlin' }
)

return {
	-- Add java binaries
	{
    "mfussenegger/nvim-dap",
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = function(_, opts)
					if type(opts.ensure_installed) == "table" then
						vim.list_extend(opts.ensure_installed, { "kotlin-language-server", "kotlin-debug-adapter" })
					end
				end,
			},
		}
	},
	-- Add java to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "kotlin" })
		end,
	},
	-- Add lsp config
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				kotlin_language_server = {},
			},
		}
	},
}
