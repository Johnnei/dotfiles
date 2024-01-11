-- Plugins that make it a decent text editor
local Util = require("lazyvim.util")

return {
	-- Add File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{
				"<leader>fe",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = Util.root.get() })
				end,
				desc = "Explorer NeoTree (root)",
			}
		},
		opts = {
			sources = { "filesystem", "buffers", "git_status", "document_symbols" },
			source_selector = {
				sources = {
					{ source = "filesystem" },
					{ source = "document_symbols" },
					{ source = "buffers" },
					{ source = "git_status" },
				},
			},
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
			document_symbols = {
				follow_cursor = true,
			},
			filesystem = {
				group_empty_dirs = true,
				scan_mode = "deep",
				filtered_items = {
					hide_by_pattern = {
						"*.iml",
					},
					always_show = {
						".gitignore",
						".gitlab-ci.yml",
					},
					never_show = {
						".DS_Store"
					},
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
			},
		},
	},
	-- Add file search
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
			{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{ "<leader><leader>", Util.telescope("files"), desc = "Find Files (root dir)" },
			{ "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			{ "<leader>/", Util.telescope("live_grep"), desc = "Grep (root dir)" },
			{ "<leader>fh", Util.telescope("help_tags"), desc = "Help" },
			{ "<leader>fc", Util.telescope("commands"), desc = "Commands" },
		},
		opts = function() return {
			defaults = {
				get_selection_window = function()
					local wins = vim.api.nvim_list_wins()
					table.insert(wins, 1, vim.api.nvim_get_current_win())
					for _, win in ipairs(wins) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].buftype == "" then
							return win
						end
					end
					return 0
				end
			}
		} end,
	},
	-- key bindings help
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = { spelling = true },
			defaults = {
				mode = { "n", "v" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader>b"] = { name = "+buffer" },
				["<leader>c"] = { name = "+code" },
				["<leader>f"] = { name = "+file/find" },
				["<leader>g"] = { name = "+git" },
				["<leader>gh"] = { name = "+hunks" },
				["<leader>s"] = { name = "+search" },
			},
		},
		config = function (_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(opts.defaults)
		end,
	},
	-- Editor Git Integration
	{
		"lewis6991/gitsigns.nvim",
		event = "LazyFile",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>ghd", function() gs.diffthis('~') end, "Diff File")
				map("n", "]h", gs.next_hunk, "Next Hunk")
				map("n", "[h", gs.prev_hunk, "Prev Hunk")
				map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
			end,
		},
	},
	-- Highlight matching symbols under cursor
	{
		"RRethy/vim-illuminate",
		event = "LazyFile",
		opts = {
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				prodivders = { "lsp" },
			},
		},
		config = function (_, opts)
			require("illuminate").configure(opts)
		end,
	},
	-- Better Buffer Close behaviour
	{
		'echasnovski/mini.bufremove',
		version = false,
		keys = {
			{
				"<leader>bd",
				function()
					local bd = require("mini.bufremove").delete
					if vim.bo.modified then
						local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
						if choice == 1 then -- Yes
							vim.cmd.write()
							bd(0)
						elseif choice == 2 then -- No
							bd(0, true)
						end
					else
						bd(0)
					end
				end,
				desc = "Delete Buffer",
			},
			{ "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
		},
	},
}
