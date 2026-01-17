return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "php" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				intelephense = {
					enabled = true
				},
			}
		}
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"phpcs",
				"php-cs-fixer",
			}
		}
	},
	{
		"nvim-neotest/neotest",
		optional = false,
		dependencies = {
			"olimorris/neotest-phpunit",
		},
		opts = {
			adapters = {
				['neotest-phpunit'] = {
					root_ignore_files = { "tests/Pest.php" }
				},
			},
		}
	}
}
