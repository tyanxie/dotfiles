-- 初始化依赖
local file_util = require("util.file")

-- 初始化返回值
local M = {}

--- 向go文件中写入package行
--- @param filepath string 文件路径
function M.write_package(filepath)
  -- 如果文件类型不是file则直接退出
  local file_type = file_util.get_type(filepath)
  if not file_type or file_type ~= "file" then
    return
  end
  -- 如果文件后缀不为go则直接返回
  if file_util.get_extension(filepath) ~= "go" then
    return
  end
  -- 获取文件所在目录名称
  local dirpath = file_util.get_dirpath(filepath)
  -- 查找目录下所有.go文件，区分test文件和普通文件
  local files = {}
  local test_files = {}
  for _, f in ipairs(vim.fn.readdir(dirpath)) do
    if f:match("%.go$") then
      if f:match("_test%.go$") then
        test_files[#test_files + 1] = dirpath .. "/" .. f
      else
        files[#files + 1] = dirpath .. "/" .. f
      end
    end
  end
  -- 优先尝试从相关文件中提取包名
  -- 如果文件是测试文件，则优先从测试文件列表中进行提取
  local package_name
  if #test_files > 0 and filepath:match("_test%.go$") then
    package_name = M.get_package_name_from_files(test_files)
  end
  if #files > 0 and not package_name then
    package_name = M.get_package_name_from_files(files)
  end
  -- 未找到包名则使用目录名称
  if not package_name then
    local dirname = vim.fn.fnamemodify(dirpath, ":t")
    -- 替换不支持的字符
    package_name = dirname:gsub("[- ]", "_")
  end
  -- 插入首行并自动保存
  file_util.write_to_file(filepath, "package " .. package_name)
end

--- 获取go文件列表中获取的package名称，返回收个匹配到的包名
--- @param files string[] 文件路径列表
--- @return string|nil package名称
function M.get_package_name_from_files(files)
  -- 遍历所有文件进行匹配
  for _, f in ipairs(files) do
    -- 匹配当前文件的package名称
    local package_name = M.get_package_name(f)
    -- 匹配到直接返回
    if package_name then
      return package_name
    end
  end
end

--- 获取go文件的package名称
--- @param filepath string 文件路径
--- @return string|nil package名称
function M.get_package_name(filepath)
  -- 遍历每一行进行匹配
  local lines = vim.fn.readfile(filepath)
  for _, line in ipairs(lines) do
    -- 匹配package名称
    local package_name = line:match("^package%s+(%g+)")
    -- 存在则直接返回
    if package_name then
      return package_name
    end
  end
  return nil
end

return M
