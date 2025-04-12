local M = {
  deepseek_api_key_name = "DEEPSEEK_API_KEY", -- deepseek api key在环境变量中的名称
}

--- 判断是否需要启用AI相关功能
--- @return boolean
function M.enable()
  return os.getenv(M.deepseek_api_key_name) ~= nil -- 当前只有在环境变量中存在DEEPSEEK_API_KEY时才启用
end

return M
