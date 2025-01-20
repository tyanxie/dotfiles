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
                filtered_items = {
                    hide_by_name = {
                        --"node_modules"
                    },
                    hide_by_pattern = { -- uses glob style patterns
                        --"*.meta",
                        --"*/src/*/tsconfig.json",
                    },
                    always_show = { -- remains visible even if other settings would normally hide it
                        ".gitignore",
                    },
                    always_show_by_pattern = { -- uses glob style patterns
                        ".env*",
                    },
                    never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                        ".DS_Store",
                        "thumbs.db",
                    },
                    never_show_by_pattern = { -- uses glob style patterns
                        --".null-ls_*",
                    },
                },
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

    -- vim-tmux-clipboard 用于跨tmux会话进行复制
    {
        "roxma/vim-tmux-clipboard",
        enabled = function()
            -- 仅在ssh环境+tmux会话中上开启，因为本机操作系统上Neovim可以和系统剪切板关联，无需通过tmux传输
            return (os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil) and os.getenv("TMUX") ~= nil
        end,
    },

    -- 在vim和tmux-pane之间智能切换
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
            "TmuxNavigatorProcessList",
        },
        keys = {
            { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },
}
