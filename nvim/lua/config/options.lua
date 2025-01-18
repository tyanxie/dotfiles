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

-- 在第120列展示高亮竖线，其颜色在init.lua中进行设置，否则无法成功
vim.opt.colorcolumn = "120"

-- 使用OSC52支持ssh复制内容到本机剪切板
-- 注意使用的终端仿真器需要支持OSC52
if os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil then
    -- 必须：设置neovim使用+寄存器
    vim.o.clipboard = "unnamedplus"

    -- wezterm不支持读取系统剪切板，因此需要自己实现一个paste函数取代原有的paste函数，否则会导致粘贴时卡住
    -- https://github.com/neovim/neovim/discussions/28010#discussioncomment-10187140
    local function paste()
        return function()
            return vim.split(vim.fn.getreg('"'), "\n")
        end
    end

    -- 修改剪切板配置，默认使用OSC52
    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
            ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
    }
    -- vim.g.clipboard = {
    --     name = "OSC 52",
    --     copy = {
    --         ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    --         ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    --     },
    --     paste = {
    --         ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    --         ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    --     },
    -- }
end
