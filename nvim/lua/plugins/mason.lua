-- cmdline tools and lsp servers
return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
        ensure_installed = {
            "stylua",
            "shfmt",
            "gopls",
            "goimports",
            "gofumpt",
            "gomodifytags",
            "impl",
            "delve",
            "protols",
            "bash-language-server",
            "shellcheck",
            "marksman",
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)
        local mr = require("mason-registry")
        mr:on("package:install:success", function()
            vim.defer_fn(function()
                -- trigger FileType event to possibly load this newly installed LSP server
                require("lazy.core.handler.event").trigger({
                    event = "FileType",
                    buf = vim.api.nvim_get_current_buf(),
                })
            end, 100)
        end)

        -- 每次更新包的时候都校验ensure_installed中的包是否正常安装
        -- 如果没有则尝试安装
        -- 如果没有正常安装，可以通过:MasonLog查看原因
        mr.refresh(function()
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    p:install()
                end
            end
        end)
    end,
}
