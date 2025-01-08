-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 1. 如果当前打开文件不是当前工作目录则将文件设置为不可编辑
-- 2. 文件内容中如果出现do not edit，则将文件设置为不可编辑
vim.api.nvim_create_autocmd("BufReadPost", {
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
