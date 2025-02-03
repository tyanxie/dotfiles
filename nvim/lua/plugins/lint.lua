return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function()
        local lint = require("lint")

        -- 按照文件类型配置使用的lint工具
        -- 支持的lint工具可以查看官方文档：https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#available-linters
        lint.linters_by_ft = {
            go = { "golangcilint" },
        }

        -- 创建一个autocmd自动执行lint
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("lint", { clear = true }),
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
