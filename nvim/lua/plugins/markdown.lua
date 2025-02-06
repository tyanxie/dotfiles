return {
    -- markdown预览器
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            require("lazy").load({ plugins = { "markdown-preview.nvim" } })
            vim.fn["mkdp#util#install"]()
        end,
        keys = {
            {
                "<leader>cp",
                ft = "markdown",
                "<cmd>MarkdownPreviewToggle<cr>",
                desc = "Markdown Preview Toggle",
            },
        },
        config = function()
            vim.cmd([[do FileType]])
        end,
    },

    -- 在neovim中渲染markdown的工具
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "echasnovski/mini.icons",
        },
        ft = { "markdown" },
        opts = {
            heading = {
                -- 控制是否在signcolumn展示标题标签
                sign = false,
            },
            code = {
                -- 控制是否在signcolumn展示代码标签
                sign = false,
            },
        },
    },
}
