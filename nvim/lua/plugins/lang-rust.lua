return {
	-- Setup Rust LSP
	{
		-- Language Server Protocol integration
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {},
			}
		}
	},
	-- Neotest integration for Rust
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = {
			"rouge8/neotest-rust",
		},
		opts = {
			adapters = {
				["neotest-rust"] = {}
			},
		}
	}
}
