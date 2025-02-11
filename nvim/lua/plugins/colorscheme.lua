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
            integrations = {
                dropbar = {
                    enabled = true,
                    color_mode = true, -- enable color for kind's texts, not just kind's icons
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
