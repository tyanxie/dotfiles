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
    provider = "deepseek",
    vendors = {
      deepseek = {
        __inherited_from = "openai",
        api_key_name = api_key_name,
        endpoint = "https://api.deepseek.com",
        model = "deepseek-coder",
      },
    },
    hints = {
      enabled = false,
    },
  },
}
