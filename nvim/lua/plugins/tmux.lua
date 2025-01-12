return {
    -- 引入 tmux 插件，标记为本地插件
    {
        name = "tmux",
        dir = "~/.config/nvim/lua/plugins/tmux",
        dev = true,
    },

    -- 引入 which-key 插件支持
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts_extend = { "spec" },
        opts = {
            spec = {
                {
                    -- 配置 <leader>t 快捷键在 which-key 中展示为 tmux 图标
                    "<leader>t",
                    mode = { "n" },
                    group = "tmux",
                    icon = {
                        icon = "",
                        hl = "WhichKeyIconGreen",
                    },
                },
            },
        },
    },
}
