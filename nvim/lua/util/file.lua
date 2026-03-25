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

--- 判断文件内容是否为空
--- @param filepath string 文件名称
--- @return boolean 文件内容是否为空，如果文件不存在则返回false
function M.is_file_empty(filepath)
  -- 读取文件内容
  local file = io.open(filepath, "r")
  if not file then
    return false
  end
  -- 获取文件大小
  local size = file:seek("end")
  -- 关闭文件
  file:close()
  -- 返回文件是否为空
  return size == 0
end

--- 判断文件是否是当前 git 仓库的临时编辑文件（如 COMMIT_EDITMSG）
--- worktree 的 git dir 在主仓库的 .git/worktrees/ 下，通过 git rev-parse 获取精确路径
--- @param bufname string 文件绝对路径
--- @param cwd string 当前工作目录
--- @return boolean
function M.is_git_edit_file(bufname, cwd)
  local git_edit_files = {
    "COMMIT_EDITMSG",
    "MERGE_MSG",
    "TAG_EDITMSG",
    "SQUASH_MSG",
    "git-rebase-todo",
  }
  local filename = vim.fn.fnamemodify(bufname, ":t")
  local matched = false
  for _, git_file in ipairs(git_edit_files) do
    if filename == git_file then
      matched = true
      break
    end
  end
  if not matched then
    return false
  end
  -- 通过 git rev-parse 获取当前工作目录对应的 git dir
  local git_dir =
    vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --git-dir 2>/dev/null"):gsub("\n$", "")
  if vim.v.shell_error ~= 0 then
    return false
  end
  -- git rev-parse --git-dir 可能返回相对路径，需要转为绝对路径
  if not vim.startswith(git_dir, "/") then
    git_dir = cwd .. "/" .. git_dir
  end
  git_dir = vim.fn.resolve(git_dir)
  -- 判断文件是否在该 git dir 下
  return vim.startswith(bufname, git_dir .. "/")
end

return M
