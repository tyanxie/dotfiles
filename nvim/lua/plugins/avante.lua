local api_key_name = "DEEPSEEK_API_KEY" -- deepseek api key在环境变量中的名称

return {
  "yetone/avante.nvim",
  enabled = os.getenv(api_key_name) ~= nil, -- 只有在环境变量中存在deepseek api key时才启用
  event = "VeryLazy",
  version = false,
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    provider = "deepseek-reasoner", -- 默认使用的模型提供者
    vendors = {
      -- deepseek r1 推理模型
      ["deepseek-reasoner"] = {
        __inherited_from = "openai",
        api_key_name = api_key_name, -- api key存储在环境变量中的名称
        endpoint = "https://api.deepseek.com",
        model = "deepseek-reasoner", -- 模型名称
        disable_tools = true, -- deepseek-reasoner不支持工具，因此需要禁用
      },
      -- deepseek v3
      ["deepseek-chat"] = {
        __inherited_from = "openai",
        api_key_name = api_key_name,
        endpoint = "https://api.deepseek.com",
        model = "deepseek-chat",
      },
    },
    file_selector = {
      provider = "snacks", -- 指定文件选择器工具
    },
    hints = {
      enabled = false,
    },
  },
}
