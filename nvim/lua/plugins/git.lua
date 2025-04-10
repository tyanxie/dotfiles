return {
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
    },
  },

  -- 提供展示git-blame信息
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = false, -- 默认不展示git-blame信息，需要的时候通过`:GitBlameToggle`命令切换开关
      message_template = " <date> • <author>", -- 展示样式模板
      date_format = "%Y/%m/%d", -- 时间格式化模板
      virtual_text_column = 1,
    },
  },

  -- git修改内容提示
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },
}
