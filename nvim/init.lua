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

require("lazy").setup("plugins")

vim.cmd.colorscheme "catppuccin"

local set = vim.opt
set.softtabstop = 2
set.tabstop = 2
set.shiftwidth = 2
set.number = true
set.expandtab = false
vim.opt.listchars = {
	tab = '»·',
	trail = '·',
}
vim.opt.list = true

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true })  -- to exit to normal mode
vim.api.nvim_set_keymap('i', '<C-g>', '<ESC>', { noremap = true }) -- <C-g> to exit to normal mode
vim.api.nvim_set_keymap('x', '<C-g>', '<ESC>', { noremap = true }) -- <C-g> to clear visual select
