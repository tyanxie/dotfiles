return {
    -- nvim-treesitter 支持代码高亮
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "proto" } },
    },

    -- nvim-lspconfig 实现语言服务器支持
    -- 需要安装 protols：
    --  方法1、cargo install protols
    --  方法2、安装预编译包并且添加进环境变量：
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = { ensure_installed = { "protols" } },
            },
        },
        opts = {
            servers = {
                protols = {},
            },
        },
    },

    -- conform 代码格式化插件
    {
        "stevearc/conform.nvim",
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = { ensure_installed = { "clang-format" } },
            },
        },
        opts = {
            formatters_by_ft = {
                proto = { "common_protobuf", lsp_format = "fallback" },
            },
            -- 自定义格式格式化工具
            formatters = {
                -- 参考官方 clang-format 进行定制：https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/clang-format.lua
                common_protobuf = {
                    command = "clang-format",
                    args = function()
                        -- 尝试向上查找 .clang-format 文件，如果找到则格式类型为 file，否则为预定义格式
                        local style =
                            "{BasedOnStyle: Google, IndentWidth: 2, ColumnLimit: 0, AlignConsecutiveAssignments: true, AlignConsecutiveDeclarations: true}"
                        local config_file = vim.fn.findfile(".clang-format", ".;")
                        if config_file ~= "" then
                            style = "file"
                        end
                        return {
                            "--assume-filename",
                            "$FILENAME",
                            "--style",
                            style,
                        }
                    end,
                },
            },
        },
    },
}
