# Install Lazy if not present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.softtabstop = 2
opt.tabstop = 2
opt.shiftwidth = 2
opt.number = true
opt.expandtab = false
-- True color support
opt.termguicolors = true
-- Force lines above/below the cursor
opt.scrolloff = 4
-- Save swap and trigger CursorHold
opt.updatetime = 200
opt.relativenumber = true -- Relative line numbers
opt.listchars = {
	tab = '»·',
	trail = '·',
}
opt.list = true
-- Status line replaces this
opt.showmode = false
-- Write on buffer changes
opt.autowrite = true
opt.undolevels = 1000
-- Case insensitive search
opt.ignorecase = true
-- I can't spell, okey?
opt.spell = true
opt.spelllang = { "en" }

require("lazy").setup("plugins")

vim.cmd.colorscheme "catppuccin"

-- Make spelling not look like LSP errors
vim.api.nvim_set_hl(0, "SpellBad", { sp = "#A6E3A1", undercurl = true })
vim.api.nvim_set_hl(0, "SpellCap", { sp = "#A6E3A1", undercurl = true })
vim.api.nvim_set_hl(0, "SpellLocal", { sp = "#A6E3A1", undercurl = true })
vim.api.nvim_set_hl(0, "SpellRare", { sp = "#A6E3A1", undercurl = true })

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end)
vim.keymap.set('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true })  -- to exit to normal mode
vim.api.nvim_set_keymap('i', '<C-g>', '<ESC>', { noremap = true }) -- <C-g> to exit to normal mode
vim.api.nvim_set_keymap('x', '<C-g>', '<ESC>', { noremap = true }) -- <C-g> to clear visual select

-- Nicer window movement
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Integrate with OS clipboard
vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})

vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
