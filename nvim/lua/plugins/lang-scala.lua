return {
	-- Scala integration (lazy because it triggers everywhere causing annoying popups on missing build configs)
	{
		"scalameta/nvim-metals",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		ft = {
			"scala",
			"sbt",
			"java",
		},
		build = ":MetalsInstall",
		opts = function()
			local metals_config = require("metals").bare_config()

			metals_config.init_options.statusBarProvider = "on"

			metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

			metals_config.settings = {
				showImplicitArguments = true,
				excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
			}

			return metals_config
		end,
		config = function(self, metals_config)
			-- Neovim uses vim.ui.select which routes to Messages which Noice routes to Notify which is awful
			vim.lsp.handlers["window/showMessageRequest"] = function(_, result)
				local actions = result.actions or {}
				local co, _ = coroutine.running()
				local Menu = require("nui.menu")

				local items = {}
				for _, action in ipairs(actions) do
					table.insert(items, Menu.item("- " .. action.title, action))
				end

				local menu = Menu({
					position = "50%",
					size = {
						width = "50%",
						height = "25%",
					},
					border = {
						style = "rounded",
						text = {
							top = result.message:gsub("\n", ""),
							top_align = "center",
						},
					},
					win_options = {
						winhighlight = "NormalFloat:Normal,FloatBorder:Normal",
					},
				}, {
						lines = items,
						on_close = function()
							coroutine.resume(co, vim.NIL)
						end,
						on_submit = function(item)
							coroutine.resume(co, item)
						end,
				})
				menu:mount()
				return coroutine.yield()
			end

			require("metals").initialize_or_attach(metals_config)
			require("telescope").load_extension("metals")
		end
	},
}
