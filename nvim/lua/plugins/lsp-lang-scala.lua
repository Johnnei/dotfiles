return {
	-- Scala integration
	{
		"scalameta/nvim-metals",
		dependencies = {
			-- LSP Integration
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/cmp-nvim-lsp",
			-- UI Improvements
			"folke/noice.nvim",
			"MunifTanjim/nui.nvim",
		},
		ft = {
			"scala",
			"sbt",
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

			metals_config.on_attach = function(_, _)
				require("metals").setup_dap()
			end

			-- Override metals/stauts to send to Noice mini
			metals_config.handlers["metals/status"] = function(_, status)
				local Manager = require("noice.message.manager")
				local Message = require("noice.message")

				if not status.hide then
					local msg = Message("metals", "message", status.text)
					msg.opts.title = "Metals"
					msg.level = ""
					msg.kind = "message"
					Manager.add(msg)
				end
			end

			return metals_config
		end,
    config = function(self, metals_config)
			local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = self.ft,
				callback = function()
					require("metals").initialize_or_attach(metals_config)
				end,
				group = nvim_metals_group,
			})
    end
	},
	-- Integrate Metals with DAP
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			dap.configurations.scala = {
				{
					type = "scala",
					request = "launch",
					name = "RunOrTest",
					metals = {
						runType = "runOrTestFile",
					},
				},
				{
					type = "scala",
					srequest = "launch",
					name = "Test Target",
					metals = {
						runType = "testTarget"
					},
				},
			}
		end,
	},
}
