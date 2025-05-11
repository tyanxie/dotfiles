local M = {
  timer = vim.uv.new_timer(), -- 定时器
  current_appearance = "", -- 记录当前外观
  colorscheme_light = "catppuccin-latte", -- 浅色主题
  colorscheme_dark = "catppuccin-mocha", -- 深色主题
}

-- 外观枚举
local appearance_light = "light"
local appearance_dark = "dark"

--- 启动主题监听任务
M.start = function()
  -- 启动时直接设置一次颜色主题
  M.refresh()
  -- 如果没有定时器则报错
  if not M.timer then
    vim.notify("初始化颜色外观监听失败", vim.log.levels.ERROR)
    return
  end
  -- 启动定时器
  M.timer:start(300, 300, M.refresh)
end

--- 执行一次刷新当前外观任务
M.refresh = function()
  if vim.fn.has("macunix") == 1 then
    -- macos
    M.refresh_darwin()
  else
    -- 其它系统
    M.set(appearance_light)
  end
end

--- macos刷新当前外观
M.refresh_darwin = function()
  M.run_command({ "defaults", "read", "-g", "AppleInterfaceStyle" }, function(stdout, _)
    -- 结果中包含Dark字符串则说明是深色模式
    if stdout:find("Dark") then
      M.set(appearance_dark)
      return
    end
    -- 默认使用浅色模式
    M.set(appearance_light)
  end)
end

--- 运行命令并调用callback，如果当前主题为空则命令会被立刻执行
--- @param cmd string[] 要执行的命令
--- @param callback fun(stdout: string, stderr: string) 执行命令后的回调函数
M.run_command = function(cmd, callback)
  -- 如果当前外观为空则立刻执行
  if M.current_appearance == "" then
    local stdout = vim.fn.system(cmd)
    callback(stdout, "")
    return
  end
  -- 外观非空，代表不是首次加载，可以异步执行
  vim.system(cmd, { text = true }, function(out)
    callback(out.stdout, out.stderr)
  end)
end

--- 指定外观并设置颜色主题
M.set = function(appearance)
  -- 如果当前外观为空则需要立即更改
  local immediately = M.current_appearance == ""
  -- 默认使用浅色主题
  if appearance == "" then
    appearance = appearance_light
  end
  -- 如果和当前外观一致则直接返回
  if appearance == M.current_appearance then
    return
  end
  -- 修改当前外观
  M.current_appearance = appearance
  -- 判断要使用的主题，默认使用浅色主题
  local colorscheme = M.colorscheme_light
  if M.current_appearance == appearance_dark then
    colorscheme = M.colorscheme_dark
  end
  -- 如果指定了sync则同步执行，否则直接异步执行
  if immediately then
    vim.cmd.colorscheme(colorscheme)
  else
    vim.schedule(function()
      vim.cmd.colorscheme(colorscheme)
    end)
  end
end

return M
