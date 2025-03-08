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

-- 时间戳转换为时间字符串，单位s
vim.api.nvim_create_user_command("ConvertTimestamp", function(opts)
  -- 按照参数长度获取时间戳文本和单位
  local text = ""
  if #opts.fargs == 0 then
    -- 没有传任何参数时获取光标下的内容作为时间戳文本
    text = vim.fn.expand("<cword>")
  elseif #opts.fargs == 1 then
    -- 只有一个参数时认为第一个参数是时间戳文本
    text = opts.fargs[1]
  else
    vim.notify("参数过多：" .. #opts.fargs, vim.log.levels.ERROR)
    return
  end

  -- 时间戳文本转为数字
  local timestamp = tonumber(text)
  -- 错误处理
  if not timestamp or timestamp < 0 then
    vim.notify("时间戳无效：" .. text, vim.log.levels.ERROR)
    return
  end

  -- 解析为时间字符串
  local result = os.date("%Y-%m-%d %H:%M:%S %z", timestamp)
  if type(result) ~= "string" then
    vim.notify("解析结果异常", vim.log.levels.ERROR)
    return
  end

  -- 创建浮动窗口
  Snacks.win({
    relative = "cursor",
    width = #result, -- 窗口宽度
    height = 1, -- 窗口高度
    row = 1, -- 显示在光标下方
    col = 0,
    border = "rounded", -- 边框样式 (可选：single/double/rounded/solid/shadow)
    title = { { " ", "Title" }, { text } }, -- 标题icon使用Title高亮组，文本为解析使用的时间戳，使用默认高亮组
    title_pos = "center",
    text = result,
    wo = {
      winhighlight = "Normal:WarningMsg", -- 使用Normal设置窗口文本的高亮组
    },
  })
end, {
  desc = "时间戳转换为时间字符串",
  nargs = "*",
})
