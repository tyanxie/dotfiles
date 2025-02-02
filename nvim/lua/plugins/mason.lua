-- cmdline tools and lsp servers
return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
        -- mason名称和lsp的对应关系可以参考mason-lspconfig中的配置：
        --  https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
        -- 可以参考mason-registry来确认软件包的安装方式：https://github.com/mason-org/mason-registry
        ensure_installed = {
            "stylua", -- github:johnnymorganz/stylua
            "lua-language-server", -- github:LuaLS/lua-language-server
            "shfmt", -- github:mvdan/sh
            "gopls", -- golang:golang.org/x/tools/gopls
            "goimports", -- golang:golang.org/x/tools/cmd/goimports
            "gofumpt", -- golang:mvdan.cc/gofumpt
            "gomodifytags", -- golang:github.com/fatih/gomodifytags
            "impl", -- golang:github.com/josharian/impl
            "delve", -- golang:github.com/go-delve/delve/cmd/dlv
            "protols", -- cargo:protols
            "bash-language-server", -- npm:bash-language-server
            "shellcheck", -- github:vscode-shellcheck/shellcheck-binaries
            "marksman", -- github:artempyanykh/marksman
            "json-lsp", -- npm:vscode-langservers-extracted
            "taplo", -- github:tamasfe/taplo
            "yaml-language-server", -- npm:yaml-language-server
            "prettier", -- npm:prettier
            "html-lsp", -- npm:vscode-langservers-extracted
            "css-lsp", -- npm:vscode-langservers-extracted
            "vtsls", -- npm:@vtsls/language-server
            "vue-language-server", -- npm:@vue/language-server
            "clangd", -- github:clangd/clangd
            "clang-format", -- pypi:clang-format
            "basedpyright", -- pypi:basedpyright
            "yapf", -- pypi:yapf
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
