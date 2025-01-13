-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- TAB
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting

-- 获取操作系统名称，Linux/Darwin
local uname = vim.uv.os_uname().sysname

-- 如果是Linux操作系统，则取消鼠标能力，防止远程服务器无法选择复制内容的问题
if uname == "Linux" then
    vim.opt.mouse = ""
end
