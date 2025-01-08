-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- set alt-bs to delete word
vim.keymap.set("i", "<M-BS>", "<C-w>", { noremap = true })

-- disable A-j and A-k to avoid switch line avoid by tmux in esc-j and esc-k
-- https://github.com/LunarVim/LunarVim/issues/1857#issuecomment-2273066106
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")
