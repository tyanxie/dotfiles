return {
    -- tokyonight
    -- 1. recommend style: light:day, dark:storm
    -- 2. recommend use with auto-dark-mode to auth change light or dark
    -- 3. do not disable tokyonight because of this is default installed theme with lazyvim
    {
        "folke/tokyonight.nvim",
        enabled = false,
        lazy = true,
        priority = 1000,
    },

    -- cyberdream
    {
        "scottmckendry/cyberdream.nvim",
        enabled = false,
        lazy = true,
        priority = 1000,
        opts = {
            transparent = true,
        },
    },

    -- nightfox
    -- recommend light: dayfox
    {
        "EdenEast/nightfox.nvim",
        enabled = false,
        lazy = false,
        priority = 1000,
        opts = {
            options = {
                transparent = false,
                styles = {
                    comments = "italic",
                },
            },
        },
    },

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
                snacks = true,
                which_key = true,
            },
        },
    },

    -- auto-dark-mode
    -- auto change dark or light mode
    {
        "f-person/auto-dark-mode.nvim",
        enabled = false,
        opts = {
            update_interval = 1000,
            set_dark_mode = function()
                vim.api.nvim_set_option_value("background", "dark", {})
                vim.cmd([[colorscheme nightfox]])
            end,
            set_light_mode = function()
                vim.api.nvim_set_option_value("background", "light", {})
                vim.cmd([[colorscheme nightfox]])
            end,
        },
    },
}
