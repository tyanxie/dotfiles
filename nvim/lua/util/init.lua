local M = {
    ---判断当前系统是否是Linux
    ---@return boolean
    is_linux = function()
        return vim.uv.os_uname().sysname == "Linux"
    end,
}

---判断当前系统是否不是Linux
---@return boolean
function M.not_linux()
    return not M.is_linux()
end

return M
