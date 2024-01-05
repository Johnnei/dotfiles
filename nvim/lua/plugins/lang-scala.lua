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
			require("metals").initialize_or_attach(metals_config)
			require("telescope").load_extension("metals")
		end
	},
}
