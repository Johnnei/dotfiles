return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			integrations = {
				mason = true,
				markdown = true,
				native_lsp = {
					enabled = true,
				},
				treesitter = true,
			},
		}
	},
}
