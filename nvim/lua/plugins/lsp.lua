return {
    -- lsp核心组件
    {
        "neovim/nvim-lspconfig",
        opts = function()
            -- 配置全局快捷键
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            vim.list_extend(keys, {
                -- 移除默认的 K 代表 Hover 的能力，在 keymaps.lua 中提供其它键位用于 Hover
                { "K", false },
                -- 设置 gi 为 Goto Implementation 减少 gI 的使用
                -- 该配置使用Fzf-lua实现了模糊查询相关的实现
                -- 参考配置：https://github.com/LazyVim/LazyVim/blob/d1529f650fdd89cb620258bdeca5ed7b558420c7/lua/lazyvim/plugins/extras/editor/fzf.lua#L294
                {
                    "gi",
                    "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>",
                    desc = "Goto Implementation",
                },
                -- 设置 U 命令为 Hover，替代默认的 K 的工作
                {
                    "U",
                    function()
                        vim.lsp.buf.hover()
                    end,
                    desc = "Hover",
                },
            })
        end,
    },

    -- lsp_signature 强大的展示函数/接口等签名插件
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {
            hint_enable = false,
            handler_opts = {
                border = "rounded",
            },
            timer_interval = 10,
            toggle_key = "<C-k>",
        },
        config = function(_, opts)
            require("lsp_signature").setup(opts)
        end,
    },
}
