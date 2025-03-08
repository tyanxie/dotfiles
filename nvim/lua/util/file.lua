local M = {}

--- 获取文件路径对应的文件的类型
--- @param filepath string 文件路径
--- @return string|nil 文件类型
function M.get_type(filepath)
    local stat = vim.uv.fs_stat(filepath)
    if stat then
        return stat.type
    else
        return nil
    end
end

--- 获取文件后缀
--- @param filepath string 文件路径
--- @return string 文件后缀
function M.get_extension(filepath)
    return vim.fn.fnamemodify(filepath, ":e")
end

--- 获取文件所在目录路径
--- @param filepath string 文件路径
--- @return string 目录路径
function M.get_dirpath(filepath)
    return vim.fn.fnamemodify(filepath, ":h")
end

--- 向文件中写入内容
--- @param filepath string 文件名称
--- @param content string 待写入的内容
function M.write_to_file(filepath, content)
    local file = io.open(filepath, "w")
    if file then
        file:write(content)
        file:close()
    end
end

return M
