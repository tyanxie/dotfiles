return {
  "uga-rosa/translate.nvim",
  event = "VeryLazy",
  config = function()
    vim.keymap.set(
      { "n", "v" },
      "<leader>ts",
      ":Translate ZH<CR>",
      { noremap = true, silent = true, desc = "Translate to chinese" }
    )
  end,
  opts = {},
}
