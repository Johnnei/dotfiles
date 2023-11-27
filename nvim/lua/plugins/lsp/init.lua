return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
		opts = {
			ensure_installed = {
				"shellcheck",
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		config = function(self, opts)
			local lspconfig = require("lspconfig")
			local mason = require("mason")
			mason.setup()
			lspconfig.rust_analyzer.setup({})
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"lua",
				"rust",
				"scala",
			},
		},
	},
}
