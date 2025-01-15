-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TAB
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting

-- 保存时禁止自动格式化
vim.g.autoformat = false

-- 上下滚动至少展示16行
vim.opt.scrolloff = 16

-- 获取操作系统名称，Linux/Darwin
local uname = vim.uv.os_uname().sysname
-- 如果是Linux操作系统，则取消鼠标能力，防止远程服务器无法选择复制内容的问题
if uname == "Linux" then
    vim.opt.mouse = ""
end

-- 在第120列展示高亮竖线，其颜色在init.lua中进行设置，否则无法成功
vim.opt.colorcolumn = "120"
