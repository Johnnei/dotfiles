return {
	{
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
			},
			---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
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
		"nvim-treesitter/nvim-treesitter",
		opts = {
			highlight = {
				enabled = true,
			},
			ensure_installed = {
				"lua",
				"rust",
				"ron",
				"toml",
				"scala",
				"haskell",
			},
		},
		config = function(self, opts)
			require("nvim-treesitter.configs").setup(opts)
		end
	},
	{
		"scalameta/nvim-metals",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		lazy = true,
		build = ":MetalsInstall",
		config = function(self, metals_config)
			require("metals").initialize_or_attach(metals_config)
		end
	},
}
