local Util = require("lazyvim.util")

return {
	-- Indentation Marks
	{
		"echasnovski/mini.indentscope",
		version = false,
		opts = {
			symbol = "╎",
			options = {
				try_as_border = true
			}
		}
	},
	-- Tabs, I want them tabs
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
			{ "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
			{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
			{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
			{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
			{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		},
		opts = {
			options = {
				-- stylua: ignore
				close_command = function(n) require("mini.bufremove").delete(n, false) end,
				-- stylua: ignore
				right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				diagnostics_indicator = function(_, _, diag)
					local icons = require("lazyvim.config").icons.diagnostics
					local ret = (diag.error and icons.Error .. diag.error .. " " or "")
						.. (diag.warning and icons.Warn .. diag.warning or "")
					return vim.trim(ret)
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)
			-- Fix bufferline when restoring a session
			vim.api.nvim_create_autocmd("BufAdd", {
				callback = function()
					vim.schedule(function()
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},
	-- Sane Status line components
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = function()
			-- PERF: we don't need this lualine require madness 🤷
			local lualine_require = require("lualine_require")
			lualine_require.require = require

			local icons = require("lazyvim.config").icons
			local colors = {
				[""] = Util.ui.fg("Special"),
				["Normal"] = Util.ui.fg("Special"),
				["Warning"] = Util.ui.fg("DiagnosticError"),
				["InProgress"] = Util.ui.fg("DiagnosticWarn"),
			}

			vim.o.laststatus = vim.g.lualine_laststatus
			return {
				options = {
					theme = "auto",
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						Util.lualine.root_dir(),
						{
							"diagnostics",
							symbols = {
								error = icons.diagnostics.Error,
								warn = icons.diagnostics.Warn,
								info = icons.diagnostics.Info,
								hint = icons.diagnostics.Hint,
							},
						},
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{ Util.lualine.pretty_path() },
					},
					lualine_x = {
						{
							function()
								-- TODO: Can I route this to Noice mini instead?
								return vim.g['metals_status'] .. vim.g['metals_bsp_status']
							end,
							cond = function()
								if not package.loaded["metals"] then
									return
								end
								return true
							end,
						},
						{
							function()
								local icon = icons.kinds.Copilot
								local status = require("copilot.api").status.data
								return icon .. (status.message or "")
							end,
							cond = function()
								if not package.loaded["copilot"] then
									return
								end
								local ok, clients = pcall(require("lazyvim.util").lsp.get_clients, { name = "copilot", bufnr = 0 })
								if not ok then
									return false
								end
								return ok and #clients > 0
							end,
							color = function()
								if not package.loaded["copilot"] then
									return
								end
								local status = require("copilot.api").status.data
								return colors[status.status or ""] or colors[""]
							end,
						},
						{
							"diff",
							symbols = {
								added = icons.git.added,
								modified = icons.git.modified,
								removed = icons.git.removed,
							},
							source = function()
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
					},
					lualine_y = {
						{ "progress", separator = " ", padding = { left = 1, right = 0 } },
						{ "location", padding = { left = 0, right = 1 } },
					},
					lualine_z = {
						function()
							return " " .. os.date("%R")
						end
					},
				},
				extensions = { "neo-tree" },
			}
		end,
	},
	-- Redesigned ui components for messages, cmdline and popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		optional = false,
		dependencies = {
			"rcarriga/nvim-notify",
			"nvim-treesitter/nvim-treesitter",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "%d+ lines yanked" },
							{ find = "%d+ fewer lines" },
							{ find = "%d+ more lines" },
						},
					},
					view = "mini",
				},
			},
		},
	},
	-- Better notifcations
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
		},
		init = function()
			-- Rely on noice to handle notifcations
		end,
	},
}
