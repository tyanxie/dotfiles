-- 强制将buffer设置为可编辑
vim.api.nvim_create_user_command("ForceEdit", function()
    vim.bo.readonly = false
    vim.bo.modifiable = true
    vim.notify("当前文件已解除不可编辑状态", vim.log.levels.WARN)
end, {
    desc = "强制解除当前文件的不可编辑限制",
})
