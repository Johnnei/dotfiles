return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "haskell" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        hls = function()
          return true
        end,
      },
    },
  },
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^6', -- Recommended
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
  },
}
