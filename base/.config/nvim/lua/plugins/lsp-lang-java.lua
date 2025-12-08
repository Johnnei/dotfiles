local Util = require("lazyvim.util")

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
local function extend_or_override(config, custom, ...)
	if type(custom) == "function" then
		config = custom(config, ...) or config
	elseif custom then
		config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
	end
	return config
end

return {
	-- Add java binaries
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = function(_, opts)
					if type(opts.ensure_installed) == "table" then
						vim.list_extend(opts.ensure_installed, { "java-test", "java-debug-adapter" })
					end
				end,
			},
		},
	},
	-- Add java to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "java" })
		end,
	},
	-- Add lsp config
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jdtls = {},
			},
			setup = {
				jdtls = function()
					-- Let jdtls handle startup
					return true
				end,
			},
		},
	},
	-- Configure Java LSP
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"folke/which-key.nvim",
			"mfussenegger/nvim-dap",
		},
		ft = { "java" },
		opts = function()
			-- local jdtls_jar = vim.fn.glob("$MASON/share/jdtls/plugins/org.eclipse.equinox.launcher.jar", false, true)
				 --cmd = { "jenv", "exec", "java", "-jar", jdtls_jar },
			return {
				-- How to find the root dir for a given filename. The default comes from
				-- lspconfig which provides a function specifically for java projects.
				root_dir = function(path)
					return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
				end,
				project_name = function(root_dir)
					return root_dir and vim.fs.basename(root_dir)
				end,

				jdtls_config_dir = function(project_name)
					return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
				end,
				jdtls_workspace_dir = function(project_name)
					return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
				end,

				cmd = { vim.fn.expand("jdtls") },
				full_cmd = function(opts)
					local fname = vim.api.nvim_buf_get_name(0)
					local root_dir = opts.root_dir(fname)
					local project_name = opts.project_name(root_dir)
					local cmd = vim.deepcopy(opts.cmd)
					if project_name then
						vim.list_extend(cmd, {
							"-configuration",
							opts.jdtls_config_dir(project_name),
							"-data",
							opts.jdtls_workspace_dir(project_name),
						})
					end
					return cmd
				end,
				dap = { hotcodereplace = "auto", config_overrides = {} },
				dep_main = {},
				settings = {
					java = {
						configuration = {
							runtimes = {
								{
									name = "OpenJDK 21",
									path = "/usr/lib/jvm/java-21-openjdk/",
									default = true,
								},
								{
									name = "OpenJDK 25",
									path = "/usr/lib/jvm/java-25-openjdk/",
								},
							},
						},
						inlayHints = {
							parameterNames = {
								enabled = "all",
							},
						},
						maven = {
							downloadSources = true,
						},
					},
				},
			}
		end,
		config = function()
			local opts = Util.opts("nvim-jdtls") or {}

			-- Find the extra bundles that should be passed on the jdtls command-line
			local bundles = {} ---@type string[]

			-- Somehow jdtls isn't able to get config info from it.
			-- Might be java version issue, maybe jenv isn't working well with mason?
			-- bundles = vim.fn.glob("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*jar", false, true)
			-- vim.list_extend(bundles, vim.fn.glob("$MASON/share/java-test/*.jar", false, true))

			local function attach_jdtls()
				local fname = vim.api.nvim_buf_get_name(0)

				-- Configuration can be augmented and overridden by opts.jdtls
				local config = extend_or_override({
					cmd = opts.full_cmd(opts),
					root_dir = opts.root_dir(fname),
					init_options = {
						bundles = bundles,
						extendedClientCapabilities = require("jdtls.capabilities")
					},
					settings = opts.settings,
					-- enable CMP capabilities
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
				}, opts.jdtls)

				-- Existing server will be reused if the root_dir matches.
				require("jdtls").start_or_attach(config)
				-- not need to require("jdtls.setup").add_commands(), start automatically adds commands
			end

			-- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
			-- depending on filetype, so this autocmd doesn't run for the first file.
			-- For that, we call directly below.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "java" },
				callback = attach_jdtls,
			})

			-- Setup keymap and dap after the lsp is fully attached.
			-- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
			-- https://neovim.io/doc/user/lsp.html#LspAttach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "jdtls" then
						local wk = require("which-key")
						wk.add({
							mode = "n",
							buffer = args.buf,
							{ "<leader>cx",  group = "extract" },
							{ "<leader>cxv", function() require("jdtls").extract_variable_all() end, desc = "Extract Variable" },
							{ "<leader>cxc", function() require("jdtls").extract_constant() end,     desc = "Extract Constant" },
							{ "gs",          function() require("jdtls").super_implementation() end, desc = "Goto Super" },
							{ "gS",          function() require("jdtls.tests").goto_subjects() end,  desc = "Goto Subjects" },
							{ "<leader>co",  function() require("jdtls").organize_imports() end,     desc = "Organize Imports" },
						})
						wk.add({
							mode = "v",
							buffer = args.buf,
							{ "<leader>c",  group = "code" },
							{ "<leader>cx", group = "extract" },
							{
								"<leader>cxm",
								"<ESC><CMD>lua require('jdtls').extract_method(true)<CR>",
								desc = "Extract Method",
							},
							{
								"<leader>cxv",
								"<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>",
								desc = "Extract Variable",
							},
							{
								"<leader>cxc",
								"<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>",
								desc = "Extract Constant",
							},
						})

						-- custom init for Java debugger
						require("jdtls").setup_dap(opts.dap)
						require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)

						-- Java Test require Java debugger to work
						-- custom keymaps for Java test runner (not yet compatible with neotest)
						wk.add({
							mode = "n",
							buffer = args.buf,
							{ "<leader>t",  group = "test" },
							{ "<leader>tt", function() require("jdtls.dap").test_class() end,          desc = "Run All Test" },
							{ "<leader>tr", function() require("jdtls.dap").test_nearest_method() end, desc = "Run Nearest Test" },
							{ "<leader>tT", function() require("jdtls.dap").pick_test() end,           desc = "Run Test" },
						})

						-- User can set additional keymaps in opts.on_attach
						if opts.on_attach then
							opts.on_attach(args)
						end
					end
				end,
			})

			-- Avoid race condition by calling attach the first time, since the autocmd won't fire.
			attach_jdtls()
		end,
	},
}
