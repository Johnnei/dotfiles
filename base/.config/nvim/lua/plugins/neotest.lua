return {
	-- Running Tests from VIM integration
	{
		"nvim-neotest/neotest",
		lazy = true,
		optional = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/nvim-nio",
		},
		opts = {
			adapters = {},
			status = { virtual_text = true },
			output = { open_on_run = true },
		},
		config = function (_, opts)
			local adapters = {}
			for name in pairs(opts.adapters) do
				adapters[#adapters + 1] = require(name)
			end
			opts.adapters = adapters
			require("neotest").setup(opts)
		end,
		keys = {
			{ '<leader>tt', function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in file" },
			{ '<leader>tT', function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Run tests in directory" },
			{ '<leader>tr', function() require("neotest").run.run() end, desc = "Run nearest test" },
			{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
			{ '<leader>ts', function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
			{ '<leader>to', function() require("neotest").output.open({ enter = true, auto_close = true}) end, desc = "Show output" },
			{ '<leader>tO', function() require("neotest").output_panel.toggle() end, desc = "Show output panel" },
			{ '<leader>tS', function() require("neotest").run.stop() end, desc = "Stop test run" },
		},
	},
}
