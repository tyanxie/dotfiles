return {
    "pocco81/auto-save.nvim",
    enabled = true,
    config = function(_, opts)
        local auto_save = require("auto-save")
        -- 初始化auto_save
        auto_save.setup(opts)
        -- 判断当前打开的是否是目录，如果是则关闭auto-save，否则打开auto-save
        if vim.fn.isdirectory(vim.fn.expand("%:p")) == 1 then
            auto_save.on()
        else
            auto_save.off()
            -- 如果不是无参数启动，则输出提示信息
            if vim.fn.argc() ~= 0 then
                vim.notify("AutoSave is diabled because not in directory")
            end
        end
    end,
    opts = {
        execution_message = {
            message = function() -- message to print on save
                return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
            end,
            dim = 0.18, -- dim the color of `message`
            cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
        },
        trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
        -- function that determines whether to save the current buffer or not
        -- return true: if buffer is ok to be saved
        -- return false: if it's not ok to be saved
        condition = function(buf)
            local fn = vim.fn
            local utils = require("auto-save.utils.data")

            if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
                return true -- met condition(s), can save
            end
            return false -- can't save
        end,
        write_all_buffers = false, -- write all buffers when the current one meets `condition`
        debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
        callbacks = { -- functions to be executed at different intervals
            enabling = nil, -- ran when enabling auto-save
            disabling = nil, -- ran when disabling auto-save
            before_asserting_save = nil, -- ran before checking `condition`
            before_saving = nil, -- ran before doing the actual save
            after_saving = nil, -- ran after doing the actual save
        },
    },
}
