local set = vim.keymap.set

-- 设置 Alt(Option) - Backspace 为删除单个单词的快捷键
set("i", "<M-BS>", "<C-w>", { desc = "Delete Word", noremap = true })

-- 智能翻页
set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- 智能快速翻页
set({ "n", "x" }, "J", "v:count == 0 ? '5gj' : '5j'", { desc = "Fast Down", expr = true, silent = true })
set({ "n", "x" }, "K", "v:count == 0 ? '5gk' : '5k'", { desc = "Fast Up", expr = true, silent = true })

-- 使用 <ctrl> - h/j/k/l 移动窗口
set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- 使用 <ctrl> - <方向键> 修改窗口大小
set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Clear search and stop snippet on escape
set({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    -- LazyVim.cmp.actions.snippet_stop()
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- 快速缩进
set("v", "<", "<gv")
set("v", ">", ">gv")

-- lazy
set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- 诊断
local diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
        go({ severity = severity })
    end
end
set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- 快速退出
set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- vim-visual-multi将C-Up和C-Down的功能增加到C-A-j和C-A-k（C-j与C-k被默认用于切换聚焦的panel）
-- 解决iTerm2下通过tmux使用时，C-Up和C-Down无法使用的问题
-- https://github.com/mg979/vim-visual-multi/blob/a6975e7c1ee157615bbc80fc25e4392f71c344d4/autoload/vm/plugs.vim#L11
set("n", "<C-A-j>", "<cmd>call vm#commands#add_cursor_down(0, v:count1)<cr>")
set("n", "<C-A-k>", "<cmd>call vm#commands#add_cursor_up(0, v:count1)<cr>")
