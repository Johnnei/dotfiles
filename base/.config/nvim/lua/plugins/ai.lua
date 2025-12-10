return {
	-- LLM Integration
	{
		"olimorris/codecompanion.nvim",
		opts = {
			ignore_warnings = true,
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},
	-- GitHub Copilot for CodeCompanion
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		lazy = true,
		opts = {
			suggestions = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true
			}
		}
	},
	{
		"echasnovski/mini.diff",
		config = function()
			local diff = require("mini.diff")
			diff.setup({
				-- Disabled by default
				source = diff.gen_source.none(),
			})
		end,
	},
}
