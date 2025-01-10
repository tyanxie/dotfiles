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
            -- 使用<leader>fh查看当前打开文件的二级父目录
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
                        -- 使用e命令递归打开所有文件夹
                        ["e"] = "expand_all_nodes",
                        -- 关闭s与S命令，防止切割窗口命令和leap命令冲突
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
