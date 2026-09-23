-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<leader>e", function()
  Snacks.explorer({ cwd = vim.uv.cwd() })
end, { desc = "Explorer (cwd)" })

map("n", "<leader>E", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer (root)" })
