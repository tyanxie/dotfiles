return -- This is what powers LazyVim's fancy-looking
-- tabs, which include filetype icons and close buttons.
{
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "<leader>bD", "<cmd>:bd<cr>", desc = "Delete Buffer and Window" },
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>bo",
      function()
        Snacks.bufdelete.other()
      end,
      desc = "Delete Other Buffers",
    },
    {
      "<leader>bA",
      function()
        Snacks.bufdelete.all()
      end,
      desc = "Delete All Buffers",
    },
  },
  config = function(_, opts)
    -- 设置catppuccin作为主题色
    opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
    -- 初始化bufferline
    require("bufferline").setup(opts)
  end,
  opts = {
    options = {
      close_command = function(n)
        Snacks.bufdelete(n)
      end,
      right_mouse_command = function(n)
        Snacks.bufdelete(n)
      end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      diagnostics_indicator = function(_, _, diag)
        local icons = require("util.icons").diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
      },
      get_element_icon = function(opts)
        return require("util.icons").ft[opts.filetype]
      end,
    },
  },
}
