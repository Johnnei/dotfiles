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
		"williamboman/mason.nvim",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "codelldb" })
			end
		end,
	},
	-- All in one Rust development plugin
	{
		'mrcjkb/rustaceanvim',
		version = '^3',
		ft = { 'rust' },
		opts = {
			tools = {
			},
			server = {
				on_attach = function(client, bufnr)
					-- register which-key mappings
					local wk = require("which-key")
					wk.register({
						["<leader>cR"] = { function() vim.cmd.RustLsp("codeAction") end, "Code Action" },
						["<leader>dr"] = { function() vim.cmd.RustLsp("debuggables") end, "Rust debuggables" },
					}, { mode = "n", buffer = bufnr })
        end,
				settings = {
					['rust-analyzer'] = {
					},
				},
			},
			dap = {
			},
		},
		config = function(_, opts)
			vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
		end,
	},
	-- Neotest integration for Rust
	{
		"nvim-neotest/neotest",
		optional = false,
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
