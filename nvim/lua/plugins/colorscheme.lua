return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function(_, opts)
    -- 初始化catppuccin
    require("catppuccin").setup(opts)
    -- 启动颜色主题同步任务
    require("util.sync_colorscheme").start()
  end,
  opts = {
    flavour = "latte", -- 可用的主题类型：latte, frappe, macchiato, mocha
    transparent_background = true, -- 是否开启透明背景
    -- 自定义高亮组
    -- 默认高亮组定义：https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups
    highlight_overrides = {
      -- 自定义覆盖所有配色高亮组
      all = function(colors)
        return {
          -- line number
          LineNr = { fg = colors.overlay0 },
          -- blink.cmp
          BlinkCmpMenu = { fg = colors.text },
          BlinkCmpMenuBorder = { fg = colors.blue },
          BlinkCmpMenuSelection = { bg = colors.surface2 },
          BlinkCmpKind = { fg = colors.blue },
          BlinkCmpDocBorder = { fg = colors.blue },
          BlinkCmpSignatureHelpBorder = { fg = colors.blue },
          BlinkCmpSignatureHelpActiveParameter = { fg = colors.mauve },
          -- snacks.nvim
          SnacksIndent = { fg = colors.overlay0 },
          SnacksIndentScope = { fg = colors.pink },
        }
      end,
      -- 自定义mocha配色高亮组
      mocha = function(mocha)
        local utils = require("catppuccin.utils.colors")
        return {
          -- visual
          Visual = { bg = mocha.surface2 },
          VisualNOS = { bg = mocha.surface2 },
          -- 搜索
          Search = { bg = utils.darken(mocha.red, 0.30, mocha.base) },
          IncSearch = { bg = utils.darken(mocha.red, 0.90, mocha.base) },
          -- lsp
          LspInlayHint = { fg = mocha.overlay2 },
        }
      end,
    },
    -- Neovim生态中其它插件的主题支持
    integrations = {
      blink_cmp = true,
      dropbar = {
        enabled = true,
        color_mode = true,
      },
      noice = true,
      snacks = {
        enabled = true,
      },
      which_key = true,
    },
  },
}
