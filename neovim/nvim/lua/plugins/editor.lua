return {
    -- neo-tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
            { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
            -- use <leader>fc go to current file's secondary parent directory
            {
                "<leader>fh",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.fn.expand("%:h:h") })
                end,
                desc = "Explorer NeoTree (secondary parent directory)",
            },
        },
        opts = {
            filesystem = {
                window = {
                    mappings = {
                        -- use "o" to open file by system default application
                        -- it's map to "system_open"" commend
                        ["o"] = function(state)
                            local node = state.tree:get_node()
                            local path = node:get_id()
                            vim.fn.jobstart({ "open", path }, { detach = true })
                        end,
                        -- disable s and S to avoid split windows
                        ["s"] = "noop",
                        ["S"] = "noop",
                    },
                },
            },
        },
    },

    -- vim visual multi
    {
        "mg979/vim-visual-multi",
    },
}
