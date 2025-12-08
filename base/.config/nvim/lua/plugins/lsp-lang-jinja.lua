return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jinja_lsp = {
					filetypes = { "yaml.jinja" },
				},
			},
		},
	},
}
