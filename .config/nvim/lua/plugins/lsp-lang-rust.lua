return {
	-- Setup Rust LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {},
			},
			setup = {
				rust_analyzer = function()
					-- Should be handled by rustaceanvim
					return true
				end
			}
		}
	},
	-- Install Rust debug binaries
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "codelldb" })
			end
		end,
	},
	-- All in one Rust development plugin
	{
		'mrcjkb/rustaceanvim',
		version = '^6',
		opts = {
			tools = {
			},
			server = {
				on_attach = function(client, bufnr)
					-- register which-key mappings
					local wk = require("which-key")
					wk.add(
						{
							{ "<leader>cR", function() vim.cmd.RustLsp("codeAction") end,   desc = "Code Action" },
							{ "<leader>dr", function() vim.cmd.RustLsp("debuggables") end,  desc = "Rust debuggables" },
							{ "<leader>E",  function() vim.cmd.RustLsp("explainError") end, desc = "Explain (Rust)" },
						},
						{ mode = "n", buffer = bufnr }
					)
				end,
				default_settings = {
					['rust-analyzer'] = {
						cargo = {
							features = "all",
						},
					},
				},
			},
			dap = {
				load_rust_types = true,
			},
		},
		config = function(_, opts)
			vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
		end,
	},
	-- Neotest integration for Rust
	{
		"nvim-neotest/neotest",
		optional = false,
		dependencies = {
			'mrcjkb/rustaceanvim',
		},
		opts = {
			adapters = {
				['rustaceanvim.neotest'] = {},
			},
		}
	}
}
