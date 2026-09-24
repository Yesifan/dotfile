vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "

-- Select the SSH provider before plugins initialize the clipboard.
require("clipboard")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "NvChad/NvChad",
    branch = "v2.5",
    lazy = false,
    import = "nvchad.plugins",
  },
}, {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },
  -- Plugin versions belong to each machine, outside the shared config.
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})

dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
require("nvchad.options")
require("nvchad.autocmds")

-- Ordinary y/d/p use the clipboard; use "_d to delete without replacing it.
vim.opt.clipboard = "unnamedplus"

vim.schedule(function()
  require("nvchad.mappings")
end)
