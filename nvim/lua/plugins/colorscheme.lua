return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            flavour = "mocha", -- 可用的主题类型：latte, frappe, macchiato, mocha
            transparent_background = true, -- 是否开启透明背景
            -- 自定义高亮组
            -- 默认高亮组定义：https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups
            highlight_overrides = {
                -- 自定义覆盖所有配色高亮组
                all = function(colors)
                    return {
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
                        -- line number
                        LineNr = { fg = mocha.overlay0 },
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
    },
}
