return {
  "ravitemer/mcphub.nvim",
  enabled = require("util.ai").enable(),
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = "MCPHub",
  build = "npm install -g mcp-hub@latest", -- 全局安装
  opts = {
    auto_approve = false, -- 不允许自动提交运行
  },
}
