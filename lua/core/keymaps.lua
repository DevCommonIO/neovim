-- ~/.config/nvim/lua/core/keymaps.lua
vim.g.mapleader = " "
local map = vim.keymap.set
map("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })