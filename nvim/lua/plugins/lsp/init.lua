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
		opts = {
			ensure_installed = {
				"rust_analyzer"
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function(self, opts)
			local lspconfig = require("lspconfig")
			local mason = require("mason")
			local masonlsp = require("mason-lspconfig")
			mason.setup()
			masonlsp.setup()
			lspconfig.rust_analyzer.setup({})
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"lua",
				"rust",
			},
		},
	},
	{
		"scalameta/nvim-metals",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = ":MetalsInstall",
		config = function(self, metals_config)
			require("metals").initialize_or_attach(metals_config)
		end
	},
}
