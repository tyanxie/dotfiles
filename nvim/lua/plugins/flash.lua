return {
  "folke/flash.nvim",
  event = "VeryLazy",
  vscode = true,
  keys = {
    {
      "s",
      mode = { "n", "x" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
  },
}
