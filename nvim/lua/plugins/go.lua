return {
  "ray-x/go.nvim",
  event = { "CmdlineEnter" },
  ft = { "go", "gomod" },
  dependencies = {
    "ray-x/guihua.lua",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- 关闭自动设置vim.diagnostic.config
    diagnostic = false,
  },
}
