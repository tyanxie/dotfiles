return {
    recommended = function()
        return LazyVim.extras.wants({
            ft = { "go", "gomod", "gowork", "gotmpl" },
            root = { "go.work", "go.mod" },
        })
    end,

    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "go", "gomod", "gowork", "gosum", "gotmpl" } },
    },

    {
        "williamboman/mason.nvim",
        opts = { ensure_installed = { "goimports", "gofumpt", "gomodifytags", "impl", "delve" } },
    },

    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                gopls = {
                    settings = {
                        gopls = {
                            -- can find settings in gopls docs: https://github.com/golang/tools/tree/master/gopls/doc
                            codelenses = {
                                gc_details = false,
                                generate = true,
                                regenerate_cgo = true,
                                run_govulncheck = true,
                                test = true,
                                tidy = true,
                                upgrade_dependency = true,
                                vendor = true,
                            },
                            hints = {
                                assignVariableTypes = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                constantValues = true,
                                functionTypeParameters = true,
                                parameterNames = true,
                                rangeVariableTypes = true,
                            },
                            analyses = {
                                fieldalignment = true,
                                nilness = true,
                                unusedparams = true,
                                unusedwrite = true,
                                useany = true,
                            },
                            usePlaceholders = false, -- 设置是否自动补全函数参数
                            completeUnimported = true,
                            staticcheck = true,
                            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                            semanticTokens = true,
                        },
                    },
                },
            },
            setup = {
                gopls = function(_, _)
                    -- workaround for gopls not supporting semanticTokensProvider
                    -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
                    LazyVim.lsp.on_attach(function(client, _)
                        if not client.server_capabilities.semanticTokensProvider then
                            local semantic = client.config.capabilities.textDocument.semanticTokens
                            if semantic then
                                client.server_capabilities.semanticTokensProvider = {
                                    full = true,
                                    legend = {
                                        tokenTypes = semantic.tokenTypes,
                                        tokenModifiers = semantic.tokenModifiers,
                                    },
                                    range = true,
                                }
                            end
                        end
                    end, "gopls")
                    -- end workaround
                end,
            },
        },
    },

    -- conform 代码格式化
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                go = { "goimports", lsp_format = "last" },
            },
        },
    },

    -- go 语言 dap 支持
    {
        "leoluz/nvim-dap-go",
        opts = {
            -- 个性化 dap 配置
            -- 参考文件：https://github.com/leoluz/nvim-dap-go/blob/main/lua/dap-go.lua
            dap_configurations = {
                {
                    type = "go",
                    name = "Debug Package(Remote)",
                    request = "launch",
                    program = "${fileDirname}",
                    -- outputMode 需要配置为 remote 才能正常看到输出内容
                    -- https://github.com/mfussenegger/nvim-dap/discussions/1407#discussioncomment-11705594
                    -- nvim-dap-go 已经有 PR 但还未合入：https://github.com/leoluz/nvim-dap-go/pull/109
                    -- 相关 issue：https://github.com/leoluz/nvim-dap-go/issues/108
                    outputMode = "remote",
                },
            },
        },
    },

    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
            },
        },
        -- mason-nvim-dap is loaded when nvim-dap loads
        config = function() end,
    },

    {
        "nvim-neotest/neotest",
        dependencies = {
            "fredrikaverpil/neotest-golang",
        },
        opts = {
            adapters = {
                ["neotest-golang"] = {
                    -- Here we can set options for neotest-golang, e.g.
                    -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
                    dap_go_enabled = true, -- requires leoluz/nvim-dap-go
                },
            },
        },
    },

    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    },

    {
        "echasnovski/mini.icons",
        opts = {
            file = {
                [".go-version"] = { glyph = "" },
                ["go.mod"] = { glyph = "" },
                ["go.sum"] = { glyph = "" },
            },
            filetype = {
                go = { glyph = "" },
                gotmpl = { glyph = "" },
            },
        },
    },
}
