-- 强制将buffer设置为可编辑
vim.api.nvim_create_user_command("ForceEdit", function()
    vim.bo.readonly = false
    vim.bo.modifiable = true
    vim.notify("当前文件已解除不可编辑状态", vim.log.levels.WARN)
end, {
    desc = "强制解除当前文件的不可编辑限制",
})

-- 在系统临时目录中创建一个临时文件并打开，并在关闭buffer时删除临时文件
-- 通过该命令配合`:set filetype`命令可以做到打开临时文件并快速处理某个类型的文件内容
vim.api.nvim_create_user_command("CreateTempFile", function()
    -- 创建临时文件
    local filename = vim.fn.tempname()
    vim.notify("创建临时文件：" .. filename .. "\n\n注意退出buffer时会自动删除该文件")
    -- 创建新的缓冲区
    local buf = vim.api.nvim_create_buf(true, false)

    -- 关联缓冲区与临时文件
    vim.api.nvim_buf_set_name(buf, filename)
    vim.api.nvim_set_current_buf(buf)

    -- 缓冲区关闭时自动删除文件
    vim.api.nvim_create_autocmd("BufDelete", {
        buffer = buf,
        callback = function()
            os.remove(filename)
            vim.notify("临时文件已删除：" .. filename, vim.log.levels.WARN)
        end,
    })

    -- 自动进入insert模式
    vim.cmd("startinsert")
end, {
    desc = "创建临时文件并打开",
})
