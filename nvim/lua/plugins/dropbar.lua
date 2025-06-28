-- IDE风格的winbar（顶部面包屑）
return {
  "Bekaboo/dropbar.nvim",
  event = "LspAttach",
  opts = {},
  keys = {
    {
      "<leader>;",
      function()
        require("dropbar.api").pick()
      end,
      desc = "Pick symbols in winbar",
    },
  },
}
