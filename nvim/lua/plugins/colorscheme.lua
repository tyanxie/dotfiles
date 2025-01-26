return {
    -- tokyonight
    -- 1. recommend style: light:day, dark:storm
    -- 2. recommend use with auto-dark-mode to auth change light or dark
    -- 3. do not disable tokyonight because of this is default installed theme with lazyvim
    {
        "folke/tokyonight.nvim",
        lazy = true,
        priority = 1000,
    },

    -- cyberdream
    {
        "scottmckendry/cyberdream.nvim",
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
