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
		end
	},
	{
		-- Yaml Schema Store
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
	{
		-- Language Server Protocol integration
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		---@class PluginLspOpts
		opts = {
			capabilities = {},
			---@type lspconfig.options
			servers = {
				lua_ls = {},
				rust_analyzer = {},
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
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Autocompletion trigger
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					-- Buffer local mappings
					local telescope = require('telescope.builtin')
					local opts = { buffer = ev.buf }
					vim.keymap.set('n', 'gd', telescope.lsp_definitions, opts)
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					vim.keymap.set('n', 'gi', telescope.lsp_implementations, opts)
					vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
					vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
					vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
					vim.keymap.set('n', 'gr', telescope.lsp_references, opts)
					vim.keymap.set('n', '<leader>f', function()
						vim.lsp.buf.format { async = true }
					end, opts)

					vim.keymap.set('n', '<leader>tt', function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run tests in file" })
					vim.keymap.set('n', '<leader>tT', function() require("neotest").run.run(vim.loop.cwd()) end, { desc = "Run tests in directory" })
					vim.keymap.set('n', '<leader>tr', function() require("neotest").run.run() end, { desc = "Run nearest test" })
					vim.keymap.set('n', '<leader>ts', function() require("neotest").summary.toggle() end, { desc = "Toggle summary" })
					vim.keymap.set('n', '<leader>to', function() require("neotest").output.open({ enter = true, autoclose = true}) end, { desc = "Show output" })
					vim.keymap.set('n', '<leader>tO', function() require("neotest").output_panel.toggle() end, { desc = "Show output panel" })
					vim.keymap.set('n', '<leader>tS', function() require("neotest").summary.toggle() end, { desc = "Stop test run" })

				end,
			})

			-- Connect to Mason
			local masonlsp = require("mason-lspconfig")
			local all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			local ensure_installed = {} ---@type string[]

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})
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
				"scala",
				"haskell",
				"yaml"
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
	{
		-- Scala integration (lazy because it triggers everywhere causing annoying popups on missing build configs)
		"scalameta/nvim-metals",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		ft = {
			"scala",
			"sbt",
			"java",
		},
		build = ":MetalsInstall",
		opts = function()
			local metals_config = require("metals").bare_config()

			-- Example of settings
			metals_config.settings = {
				showImplicitArguments = true,
				excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
			}

			return metals_config
		end,
		config = function(self, metals_config)
			require("metals").initialize_or_attach(metals_config)
		end
	},
	-- Running Tests from VIM integration
	{
		"nvim-neotest/neotest",
		lazy = true,
		dependencies = {
			"rouge8/neotest-rust",
		},
		config = function (_, opts)
			require("neotest").setup({
				adapters = {
					require("neotest-rust")
				},
			})
		end
	},
}
