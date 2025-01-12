--- 判断 tmux 是否未安装
--- @return boolean _ true 代表未安装，false 代表已安装
local function not_installed()
    if os.execute("which tmux") == 0 then
        return false
    end
    vim.notify("tmux未安装，请安装tmux以执行", vim.log.levels.ERROR)
    return true
end

--- 判断当前是否不在 tmux 会话中
--- @return boolean _ false 代表在 tmux 会话中
local function not_in_session()
    -- TMUX环境变量存在的时候代表当前在 tmux 则会话中
    if os.getenv("TMUX") then
        return false
    end
    vim.notify("当前不在tmux会话中，请进入tmux会话以执行", vim.log.levels.ERROR)
    return true
end

--- 校验所有基础内容是否不通过
--- @return boolean _ true 代表校验不通过，false 代表校验通过
local function invalid_basic_check()
    -- 校验 tmux 安装
    if not_installed() then
        return true
    end
    -- 校验当前处于 tmux 会话中
    if not_in_session() then
        return true
    end
    -- 所有校验都通过
    return false
end

--- 切换到指定的会话，如果失败会打印错误并返回 false
--- @param session_name string 会话名称
--- @return boolean success 是否成功
local function tmux_switch(session_name)
    -- 切换到选择的 session
    local output = vim.fn.system("tmux switch-client -t " .. session_name)
    -- 执行失败需要报错
    if vim.v.shell_error ~= 0 then
        -- 移除 output 末尾的空白字符并输出错误信息
        vim.notify("切换会话失败：" .. output:gsub("%s+$", ""), vim.log.levels.ERROR)
        return false
    end
    return true
end

--- 切换会话
local function switch()
    -- 基本参数校验
    if invalid_basic_check() then
        return
    end

    -- 查找所有的 tmux 会话
    local sessions = vim.fn.systemlist("tmux ls")

    -- 提取会话名称列表，同时记录是否存在当前已经选择的会话
    local session_names = {}
    for _, session in ipairs(sessions) do
        -- 获取 session 名称
        local name = session:match("^(%S+):")
        -- 如果名称为空则跳过
        if name == "" then
            goto continue
        end
        -- 判断是否是当前的会话，如果是则标记存在会话并跳过
        local is_current = session:match(" %(attached%)$")
        if is_current then
            goto continue
        end
        -- 将当前会话写入列表
        table.insert(session_names, name)
        ::continue::
    end

    -- 没有会话进行特殊处理
    if #session_names == 0 then
        vim.notify("未找到其它会话", vim.log.levels.WARN)
        return
    end

    -- 让用户选择一个会话
    vim.ui.select(session_names, { prompt = "选择一个会话：" }, function(choice)
        -- 用户没有选择内容则直接返回
        if not choice then
            return
        end
        -- 切换到选择的会话，执行失败直接返回
        if not tmux_switch(choice) then
            return
        end
    end)
end

--- 创建会话
local function new()
    -- 基础校验
    if invalid_basic_check() then
        return
    end

    -- 提示用户输入会话名称
    vim.ui.input({ prompt = "输入会话名称：" }, function(session_name)
        -- 参数校验
        if session_name == nil then
            -- 用户没有输入任何内容，直接返回
            return
        elseif session_name == "" then
            -- 用户输入的内容为空
            vim.notify("会话名称不可为空", vim.log.levels.WARN)
            return
        elseif not session_name:match("^[a-zA-Z_][a-zA-Z0-9_-]*$") then
            -- 会话名称格式错误
            vim.notify("会话名称格式错误", vim.log.levels.ERROR)
            return
        end

        -- 判断会话是否已经存在
        if os.execute("tmux has -t " .. session_name) == 0 then
            vim.notify("会话已经存在：" .. session_name, vim.log.levels.WARN)
            return
        end

        -- 执行创建会话命令，注意需要携带 -d 参数，代表后台创建，否则在会话中会创建失败
        local output = vim.fn.system("tmux new -d -s " .. session_name)
        -- 执行失败需要报错
        if vim.v.shell_error ~= 0 then
            -- 移除 output 末尾的空白字符并输出
            vim.notify(string.format("创建会话失败：" .. output:gsub("%s+$", "")), vim.log.levels.ERROR)
            return
        end

        -- 执行切换会话的命令，如果失败则直接返回
        if not tmux_switch(session_name) then
            return
        end
    end)
end

-- 返回插件信息
return {
    setup = function() end,
    new = new,
    switch = switch,
}
