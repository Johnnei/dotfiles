-- PLugins that improve coding experience
return {
	-- code snippets
	{
		"L3MON4D3/LuaSnip",
		tag = "v2.1.1",
		run = "make install_jsregexp",
		lazy = true,
	},
	-- Rust Crates Support
	{
		"Saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		opts = {
			src = {
				cmp = { enabled = true },
			},
		},
	},
	-- Github Copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		opts = {
			suggestions = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true
			}
		}
	},
	-- cmp integration for copilot
	{
		"zbirenbaum/copilot-cmp",
		dependencies = "copilot.lua",
		opts = {},
		config = function(_, opts)
			local copilot_cmp = require("copilot_cmp")
			copilot_cmp.setup(opts)
			-- attach cmp source whenever copilot attaches
			-- fixes lazy-loading issues with the copilot cmp source
			require("lazyvim.util").lsp.on_attach(function(client)
				if client.name == "copilot" then
					copilot_cmp._on_insert_enter({})
				end
			end)
		end,
	},
	-- auto completion
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"Saecki/crates.nvim",
			"zbirenbaum/copilot-cmp",
		},
		opts = function()
			vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
			local cmp = require("cmp")
			local defaults = require("cmp.config.default")()
			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<S-CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<C-CR>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
				}),
				sources = cmp.config.sources(
					{
						{
							name = "copilot",
							group_index = 1,
							priority = 100,
						},
					},
					{
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "path" },
					},
					{
						{ name = "buffer" },
					},
					{
						{ name = "crates" },
					}
				),
				formatting = {
					format = function(_, item)
						local icons = require("lazyvim.config").icons.kinds
						if icons[item.kind] then
							item.kind = icons[item.kind] .. item.kind
						end
						return item
					end,
				},
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = defaults.sorting,
			}
		end,
		---@param opts cmp.ConfigSchema
		config = function(_, opts)
			for _, source in ipairs(opts.sources) do
				source.group_index = source.group_index or 1
			end
			require("cmp").setup(opts)
		end,
	},
	-- Add quick comment key mappings
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		version = false,
		opts = {},
	},
	-- Insert matching surrounding tokens
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		version = false,
		opts = {},
	},
}
