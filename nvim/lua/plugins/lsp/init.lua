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
}
