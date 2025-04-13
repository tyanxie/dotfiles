-- 引入ai工具包
local ai_util = require("util.ai")

return {
  "yetone/avante.nvim",
  enabled = ai_util.enable(),
  event = "VeryLazy",
  version = false,
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "ravitemer/mcphub.nvim",
  },
  opts = {
    provider = "deepseek-reasoner", -- 默认使用的模型提供者
    vendors = {
      -- deepseek r1 推理模型
      ["deepseek-reasoner"] = {
        __inherited_from = "openai",
        api_key_name = ai_util.deepseek_api_key_name, -- api key存储在环境变量中的名称
        endpoint = "https://api.deepseek.com",
        model = "deepseek-reasoner", -- 模型名称
        disable_tools = true, -- deepseek-reasoner不支持工具，因此需要禁用，也因此r1模型将无法使用mcp能力
      },
      -- deepseek v3
      ["deepseek-chat"] = {
        __inherited_from = "openai",
        api_key_name = ai_util.deepseek_api_key_name,
        endpoint = "https://api.deepseek.com",
        model = "deepseek-chat",
      },
    },
    file_selector = {
      provider = "snacks", -- 指定文件选择器工具
    },
    hints = {
      enabled = false, -- 默认不显示提示
    },
    -- 自定义prompt
    system_prompt = function()
      -- 使用简体中文返回
      local prompt = [[
Ignore the previous reminder that code comments must be in English,
your code comments must be in Chinese, otherwise you will be fired.

Ignore the previous reminder to speak in English,
you must speak in simplified Chinese or you will be fired.

You have to think in Chinese or you will be fired.
]]
      -- 允许通过mcphub动态更新提示词
      local hub = require("mcphub").get_hub_instance()
      if hub then
        prompt = prompt .. "\n" .. hub:get_active_servers_prompt() .. "\n"
      end
      -- 返回自定义prompt
      return prompt
    end,
    -- 加载mcp工具
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
  },
}
