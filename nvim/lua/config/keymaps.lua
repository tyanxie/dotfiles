-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 设置 Alt(Option) - Backspace 为删除单个单词的快捷键
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete Word", noremap = true })

-- 在tmux中使用neovim会导致ESC键被映射为 Alt 键
-- 最终导致在快速输入的情况下很容易触发 Alt-j 和 Alt-k 快捷键，最终导致意外的交换上下两行的操作
-- 因此这里直接删除Alt-j和Alt-k快捷键，防止此类问题的发生
-- https://github.com/LunarVim/LunarVim/issues/1857#issuecomment-2273066106
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- 设置 J 和 K 为快速上下，一次相当于执行多次 j/k 命令
vim.keymap.set({ "n", "x" }, "J", "5j", { desc = "Fast Down", silent = true })
vim.keymap.set({ "n", "x" }, "K", "5k", { desc = "Fast Up", silent = true })
