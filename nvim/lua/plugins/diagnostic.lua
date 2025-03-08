-- 初始化诊断信息配置
local icons = require("util.icons")
vim.diagnostic.config({
  bufferline = true,
  float = true,
  hdlr = false,
  underline = true,
  update_in_insert = false,
  virtual_text = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
})

-- 美化诊断信息展示
return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  opts = {
    preset = "ghost",
    options = {
      show_source = true, -- 显示诊断来源
    },
  },
}
