-- 创建augroup
local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- 文件有变动的时候重载文件
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- 复制时高亮
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank()
    end,
})

-- 窗口大小改变同时改变splits的大小
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- 打开buffer时光标定位在上次打开的位置
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- 使用q时关闭一些类型的文件
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

-- 1. 如果当前打开文件不是当前工作目录则将文件设置为不可编辑
-- 2. 文件内容中如果出现do not edit，则将文件设置为不可编辑
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("donotedit"),
    pattern = "*",
    callback = function()
        -- 当前缓冲区序列
        local bufnr = vim.api.nvim_get_current_buf()
        -- 当前缓冲区文件绝对路径
        local bufname = vim.api.nvim_buf_get_name(bufnr)

        -- 1. 如果当前打开文件不是当前工作目录则将文件设置为不可编辑
        -- 文件路径存在才进行判断
        if bufname ~= "" then
            -- 当前工作目录
            local cwd = vim.fn.getcwd()
            -- 判断当前文件是否是当前工作目录的子文件，如果不是则设置为不可编辑
            if string.sub(bufname, 1, string.len(cwd)) ~= cwd then
                vim.notify("文件不在当前工作目录下，已被设置为不可编辑：" .. bufname)
                -- 将缓冲区设置为只读
                vim.bo.readonly = true
                -- 将缓冲区设置为不可编辑
                vim.bo.modifiable = false
                -- 设置完成后直接返回
                return
            end
        end

        -- 2. 文件内容中如果出现do not edit，则将文件设置为不可编辑
        -- 本文件不进行判断
        if bufname == os.getenv("HOME") .. "/.config/nvim/lua/config/autocmds.lua" then
            vim.notify("当前文件跳过校验 'DO NOT EDIT'：" .. bufname)
            return
        end
        -- 仅判断前5行内容，以减少性能开销
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
        for _, line in ipairs(lines) do
            -- 忽略大小写进行判断
            if string.lower(line):match("do not edit") then
                vim.notify("文件被标记为 'DO NOT EDIT'，已被设置为不可编辑：" .. bufname)
                -- 将缓冲区设置为只读
                vim.bo.readonly = true
                -- 将缓冲区设置为不可编辑
                vim.bo.modifiable = false
                -- 设置完成后直接返回
                return
            end
        end
    end,
})
