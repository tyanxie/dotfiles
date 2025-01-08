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
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            {
                "<leader>gg",
                function()
                    require("snacks.lazygit")()
                end,
                desc = "Lazygit (cwd)",
            },
            {
                "<leader>gG",
                function()
                    require("snacks.lazygit")({ cwd = LazyVim.root.git() })
                end,
                desc = "Lazygit (Root Dir)",
            },
        },
    },

    {
        "sindrets/diffview.nvim",
        keys = {
            {
                "<leader>gd",
                "<CMD>DiffviewOpen<CR>",
                desc = "Diff View Open",
            },
            {
                "<leader>gD",
                "<CMD>DiffviewClose<CR>",
                desc = "Diff View Close",
            },
        },
    },

    {
        "f-person/git-blame.nvim",
        -- load the plugin at startup
        event = "VeryLazy",
        -- Because of the keys part, you will be lazy loading this plugin.
        -- The plugin wil only load once one of the keys is used.
        -- If you want to load the plugin at startup, add something like event = "VeryLazy",
        -- or lazy = false. One of both options will work.
        opts = {
            -- your configuration comes here
            -- for example
            enabled = true, -- if you want to enable the plugin
            message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
            date_format = "%m-%d-%Y %H:%M:%S", -- template for the date, check Date format section for more options
            virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
        },
    },
}
