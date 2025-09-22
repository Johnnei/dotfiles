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
			lsp = {
				enabled = true,
				actions = true,
				completion = true,
				hover = true,
			},
		},
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
			-- "zbirenbaum/copilot-cmp",
		},
		opts = function()
			vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
					return false
				end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end

			local cmp = require("cmp")
			local compare = require("cmp.config.compare")
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
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<Tab>"] = function(fallback)
						if vim.bo.buftype ~= "prompt" and has_words_before() then
							cmp.confirm({ select = true })
						else
							fallback()
						end
					end,
					["<S-Tab>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<C-Tab>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
				}),
				sources = cmp.config.sources({
					-- { name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}, {
					{ name = "crates" },
				}),
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
				sorting = {
					priority_weight = 2,
					comparators = {
						-- Exact LSP matches before LLM guesses
						compare.exact,
						-- cmp default, except exact is moved first.
						compare.offset,
						compare.score,
						compare.recently_used,
						compare.locality,
						compare.kind,
						compare.length,
						compare.order,
					},
				},
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
	-- Refactoring tools
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		lazy = false,
		keys = {
			{ "<leader>re", "<cmd>Refactor extract <cr>", desc = "Extract Method", mode = { "x" } },
			{ "<leader>rv", "<cmd>Refactor extract_var <cr>", desc = "Extract Variable", mode = { "x" } },
		},
		config = function()
			require("refactoring").setup()
		end,
	},
}
