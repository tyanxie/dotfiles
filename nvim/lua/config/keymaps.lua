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
-- 参考lazyvim的smark jk实现：https://github.com/LazyVim/LazyVim/blob/1e83b4f843f88678189df81b1c88a400c53abdbc/lua/lazyvim/config/keymaps.lua#L8
vim.keymap.set({ "n", "x" }, "J", "v:count == 0 ? '5gj' : '5j'", { desc = "Fast Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "K", "v:count == 0 ? '5gk' : '5k'", { desc = "Fast Up", expr = true, silent = true })

-- vim-visual-multi将C-Up和C-Down的功能增加到C-A-j和C-A-k（C-j与C-k被默认用于切换聚焦的panel）
-- 解决iTerm2下通过tmux使用时，C-Up和C-Down无法使用的问题
-- https://github.com/mg979/vim-visual-multi/blob/a6975e7c1ee157615bbc80fc25e4392f71c344d4/autoload/vm/plugs.vim#L11
vim.keymap.set("n", "<C-A-j>", "<cmd>call vm#commands#add_cursor_down(0, v:count1)<cr>")
vim.keymap.set("n", "<C-A-k>", "<cmd>call vm#commands#add_cursor_up(0, v:count1)<cr>")
