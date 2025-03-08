-- 使用 <ctrl> - h/j/k/l 在终端中移动光标所在的窗口
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- 图片展示支持
    image = {
      enabled = true,
      force = true, -- 一般都会使用wezterm或kitty，因此直接强制展示
    },
    indent = { enabled = true }, -- 可视化显示缩进
    input = { enabled = true }, -- 替代vim.input
    scope = { enabled = true },
    notifier = { enabled = true }, -- 使用snacks.notifier替代原始的vim.notify
    scroll = { enabled = true }, -- 平滑滚动
    words = { enabled = true },
    statuscolumn = {
      folds = {
        open = true, -- show open fold icons
        git_hl = true, -- use Git Signs hl for fold icons
      },
    },
    picker = {
      enabled = true,
      layout = {
        cycle = true,
        preset = function()
          return vim.o.columns >= 120 and "default" or "vertical"
        end,
        layout = {
          width = 0.9,
          height = 0.9,
        },
      },
      win = {
        input = {
          keys = {
            -- Alt-Backspace删除单词
            ["<a-bs>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
            -- 使用flash插件快速选择
            ["<a-s>"] = { "flash", mode = { "n", "i" } },
            ["s"] = { "flash" },
          },
        },
      },
      actions = {
        -- 使用flash插件快速选择
        flash = function(picker)
          require("flash").jump({
            pattern = "^",
            label = { after = { 0, 0 } },
            search = {
              mode = "search",
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
    },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    terminal = {
      enabled = true,
      win = {
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        },
      },
    },
    dashboard = {
      preset = {
        -- 仪表盘header内容，可以在该网站使用ANSI Shadow字体生成：https://www.patorjk.com/software/taag
        header = [[
████████╗   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
╚══██╔══╝   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
   ██║█████╗██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
   ██║╚════╝██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
   ██║      ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
   ╚═╝      ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":CreateTempFile" },
          {
            icon = " ",
            key = "g",
            desc = "Find Text",
            action = ":lua Snacks.dashboard.pick('live_grep')",
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = ":lua Snacks.dashboard.pick('oldfiles')",
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
  keys = {
    -- notifier
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },

    -- terminal
    {
      "<C-/>",
      function()
        Snacks.terminal.toggle()
      end,
      mode = { "n", "t" },
      desc = "Toggle Terminal",
    },
    -- 部分终端模拟器（如wezterm）会将<C-/>解释为<C-_>，因此这里需要增加<C-_>的快捷键
    {
      "<C-_>",
      function()
        Snacks.terminal.toggle()
      end,
      mode = { "n", "t" },
      desc = "Toggle Terminal",
    },

    -- 搜索
    -- 搜索当前工作目录
    {
      "<leader>/",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep",
    },
    -- 输入目标目录进行搜索
    {
      "<leader>sG",
      function()
        vim.ui.input({
          prompt = "target directory",
          default = vim.fn.getcwd(),
        }, function(input)
          if input and input ~= "" then
            Snacks.picker.grep({ cwd = input })
          end
        end)
      end,
      desc = "Grep (input target directory)",
    },

    -- 查找文件
    -- 查找工作目录下的文件
    {
      "<leader><space>",
      function()
        Snacks.picker.files()
      end,
      desc = "Find Files",
    },
    -- 输入目标目录进行查找
    {
      "<leader>sF",
      function()
        vim.ui.input({
          prompt = "target directory",
          default = vim.fn.getcwd(),
        }, function(input)
          if input and input ~= "" then
            Snacks.picker.files({ cwd = input })
          end
        end)
      end,
      desc = "Find Files (input target directory)",
    },

    -- git
    -- 查看git commit列表
    {
      "<leader>gc",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git Log",
    },
    -- 查看git diff列表
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (hunks)",
    },
    -- 查看git status变化列表
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
  },
}
