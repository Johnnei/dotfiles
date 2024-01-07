return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			integrations = {
				cmp = true,
				gitsigns = true,
				illuminate = true,
				mason = true,
				markdown = true,
				native_lsp = {
					enabled = true,
				},
				telescope = true,
				treesitter = true,
				neotest = true,
				neotree = true,
				noice = true,
				notify = true,
				which_key = true,
			},
		}
	},
}
