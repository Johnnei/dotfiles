local Util = require("lazyvim.util")

return {
	{
		-- Build tool management
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"stylua",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local registry = require("mason-registry")
			-- Ensure all tools are installed
			registry.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local pkg = registry.get_package(tool)
					if not pkg:is_installed() then
						pkg:install()
					end
				end
			end)
		end
	},
	{
		-- Yaml Schema Store
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
	-- Improve Neovim DevX
	{
		"folke/neodev.nvim",
		lazy = true,
		dependencies = {
				"rcarriga/nvim-dap-ui",
		},
		opts = {
			library = {
				plugins = {
					"nvim-dap-ui",
				},
				types = true,
			},
		},
	},
	{
		-- Language Server Protocol integration
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"folke/neodev.nvim",
		},
		---@class PluginLspOpts
		opts = {
			capabilities = {},
			inlay_hints = {
				enabled = true,
			},
			codelens = {
				enabled = true,
			},
			---@type lspconfig.options
			servers = {
				lua_ls = {},
				hls = {
					mason = false,
				},
				jsonls = {},
				postgres_lsp = {},
				yamlls = {
					capabilities = {
						textDocument = {
							foldingRange = {
								dynamicRegistration = false,
								lineFoldingOnly = true,
							},
						},
					},
						-- lazy-load schemastore when needed
					on_new_config = function(new_config)
						new_config.settings.yaml.schemas = vim.tbl_deep_extend(
							"force",
							new_config.settings.yaml.schemas or {},
							require("schemastore").yaml.schemas {
								extra = {
									{
										description = "devstack",
										fileMatch = "devstack.yaml",
										name = "devstack.yaml",
										url = "https://devstack.agodadev.io/api/v1/schema/devstack-v1.json",
									},
								},
							}
						)
					end,
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							keyOrdering = false,
							format = {
								enable = true,
							},
							validate = true,
							schemaStore = {
								-- Must disable built-in schemaStore support to use
								-- schemas from SchemaStore.nvim plugin
								enable = false,
								-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
								url = "",
							},
						},
					},
				},
			},
			---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
			setup = {
					yamlls = function()
					require("lazyvim.util").lsp.on_attach(function(client, _)
						if client.name == "yamlls" then
							client.server_capabilities.documentFormattingProvider = true
						end
					end)
			end,
			},
		},
		config = function(self, opts)
			local servers = opts.servers
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				{},
				opts.capabilities
			)

			-- Wire up keymaps
			Util.lsp.on_attach(function(client, buffer)
				local telescope = require('telescope.builtin')

				local keys = {
					{ 'gd', telescope.lsp_definitions, desc = "Goto Definition" },
					{ 'gD', vim.lsp.buf.declaration, desc = "Goto Declaration" },
					{ 'K', function() return vim.lsp.buf.hover() end, desc = "Hover" },
					{ 'gi', telescope.lsp_implementations, desc = "Goto Implementation" },
					{ 'gK', function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
					{ "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
					{ 'gy', vim.lsp.buf.type_definition, desc = "Type Definition" },
					{
						'<leader>cr',
						function()
							return ":IncRename " .. vim.fn.expand("<cword>")
						end,
						desc = "Rename",
						expr = true,
					},
					{ '<leader>ca', vim.lsp.buf.code_action, mode = { 'n', 'v' }, desc = "Code Action" },
					{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
					{ "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
					{ 'gr', telescope.lsp_references, desc = "Goto Reference" },
					{
						'<leader>cf',
						function()
							vim.lsp.buf.format { async = true }
						end,
						desc = "Format",
					},
					{
						'<leader>fs',
						function()
							telescope.lsp_dynamic_workspace_symbols({
								symbols = require("lazyvim.config").get_kind_filter()
							})
						end,
						desc = "Goto Symbol (Workspace)"
					},
					{
						'<leader>fS',
						function()
							telescope.lsp_document_symbols({
								symbols = require("lazyvim.config").get_kind_filter()
							})
						end,
						desc = "Goto Symbol (Document)"
					},
				}

				for _, keymap in ipairs(keys) do
					local key_opts = {}
					if keymap.desc then
						key_opts.desc = keymap.desc
					end

					if keymap.expr then
						key_opts.expr = keymap.expr
					end
					key_opts.buffer = buffer

					vim.keymap.set(keymap.mode or 'n', keymap[1], keymap[2], key_opts)
				end
			end)

			-- Connect to Mason
			local masonlsp = require("mason-lspconfig")
			local all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			local ensure_installed = {} ---@type string[]

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})


				if opts.setup[server] and opts.setup[server](server, server_opts) then
					-- Other way / plugin to set up this server
					return
				end
				require("lspconfig")[server].setup(server_opts)
			end

			for server, server_opts in pairs(servers) do
				-- server cannot be installed by mason-lspconfig, install directly
				if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
					setup(server)
				else
					ensure_installed[#ensure_installed + 1] = server
				end
			end

			masonlsp.setup({
				ensure_installed = ensure_installed,
				handlers = { setup },
			})
		end
	},
	{
		-- AST based highlghting
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		opts = {
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			ensure_installed = {
				"lua",
				"rust",
				"ron",
				"toml",
				"haskell",
				"yaml",
				"vim",
				"vimdoc",
				"regex",
				"bash",
				"markdown",
				"markdown_inline",
				"json",
				"scala",
			},
		},
		config = function(self, opts)
			require("nvim-treesitter.configs").setup(opts)
		end
	},
	{
		-- Add scope of the current line to top of window
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			max_lines = 3,
		},
	},
}
