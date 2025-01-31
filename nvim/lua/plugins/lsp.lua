local icons = require("util.icons")
vim.diagnostic.config({
    bufferline = true,
    float = true,
    hdlr = false,
    underline = true,
    update_in_insert = false,
    virtual_text = {
        spacing = 0,
        source = "if_many",
        prefix = "●",
    },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
        },
    },
})

-- 通用初始化lsp函数
local function setup(server, opts)
    -- 如果disabled为true则直接返回
    if opts.disabled == true then
        vim.notify("lsp server [" .. server .. "] is disabled")
        return
    end

    -- 生成capabilities，用于让lsp服务器知道当前支持哪些lsp能力
    local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(), -- neovim自带支持的lsp能力
        require("blink-cmp").get_lsp_capabilities(), -- blink支持的lsp能力
        opts.capabilities or {} -- opts中配置的lsp能力
    )

    -- 赋值新的capabilities配置选项
    opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
    }, opts)

    -- 初始化lsp
    require("lspconfig")[server].setup(opts)
end

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = { "mason.nvim" },
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        config = function()
            -- LspAttach事件监听
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function()
                    vim.keymap.set("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
                    vim.keymap.set("n", "gd", function()
                        require("fzf-lua").lsp_definitions({ jump_to_single_result = true, ignore_current_line = true })
                    end, { desc = "Goto Definition" })
                    vim.keymap.set("n", "gr", function()
                        require("fzf-lua").lsp_references({ jump_to_single_result = true, ignore_current_line = true })
                    end, { desc = "References", nowait = true })
                    vim.keymap.set("n", "gi", function()
                        require("fzf-lua").lsp_implementations({
                            jump_to_single_result = true,
                            ignore_current_line = true,
                        })
                    end, { desc = "Goto Implementation" })
                    vim.keymap.set("n", "gy", function()
                        require("fzf-lua").lsp_typedefs({ jump_to_single_result = true, ignore_current_line = true })
                    end, { desc = "Goto T[y]pe Definition" })
                    vim.keymap.set("n", "gD", function()
                        require("fzf-lua").lsp_declarations({ jump_to_single_result = true, ignore_current_line = true })
                    end, { desc = "Goto Declaration" })
                    vim.keymap.set("n", "U", function()
                        return vim.lsp.buf.hover()
                    end, { desc = "Hover" })
                    vim.keymap.set("n", "gk", function()
                        return vim.lsp.buf.signature_help()
                    end, { desc = "Signature Help" })
                    vim.keymap.set("i", "<c-k>", function()
                        return vim.lsp.buf.signature_help()
                    end, { desc = "Signature Help" })
                    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
                    -- vim.keymap.set({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
                    -- vim.keymap.set("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh & Display Codelens" })
                    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
                    vim.keymap.set("n", "]]", function()
                        Snacks.words.jump(vim.v.count1)
                    end, { desc = "Next Reference" })
                    vim.keymap.set("n", "[[", function()
                        Snacks.words.jump(-vim.v.count1)
                    end, { desc = "Prev Reference" })
                end,
            })

            -- 配置所有lsp

            -- lua
            setup("lua_ls", {
                settings = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                        },
                        diagnostics = {
                            globals = {},
                        },
                        codeLens = {
                            enable = true,
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                        doc = {
                            privateName = { "^_" },
                        },
                        hint = {
                            enable = true,
                            setType = false,
                            paramType = true,
                            paramName = "Disable",
                            semicolon = "Disable",
                            arrayIndex = "Disable",
                        },
                    },
                },
            })

            -- golang
            setup("gopls", {
                settings = {
                    gopls = {
                        -- 可以在gopls的文档中找到配置项：https://github.com/golang/tools/blob/master/gopls/doc/settings.md
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
            })

            -- shell
            setup("bashls", {})

            -- yaml
            setup("yamlls", {
                -- Have to add this for yamlls to understand that we support line folding
                capabilities = {
                    textDocument = {
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true,
                        },
                    },
                },
                -- lazy-load schemastore when needed
                on_new_config = function(new_config)
                    new_config.settings.yaml.schemas = vim.tbl_deep_extend(
                        "force",
                        new_config.settings.yaml.schemas or {},
                        require("schemastore").yaml.schemas()
                    )
                end,
                settings = {
                    redhat = { telemetry = { enabled = false } },
                    yaml = {
                        keyOrdering = false,
                        format = {
                            enable = true,
                        },
                        validate = true,
                        schemaStore = {
                            -- Must disable built-in schemaStore support to use
                            -- schemas from SchemaStore.nvim plugin
                            enable = false,
                            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                            url = "",
                        },
                    },
                },
            })

            -- toml
            setup("taplo", {})

            -- json
            setup("jsonls", {
                -- lazy-load schemastore when needed
                on_new_config = function(new_config)
                    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
                    vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
                end,
                settings = {
                    json = {
                        format = {
                            enable = true,
                        },
                        validate = { enable = true },
                    },
                },
            })

            -- protobuf
            setup("protols", {})

            -- markdown
            setup("marksman", {})

            -- html
            setup("html", {})

            -- css
            setup("cssls", {})
        end,
    },

    -- 基于lsp支持的美化工具，提供代码位置面包屑等功能
    -- https://nvimdev.github.io/lspsaga/
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- 在有code_action的位置显示电灯泡
            -- https://nvimdev.github.io/lspsaga/lightbulb/
            lightbulb = {
                enable = false,
                sign = false,
            },
            -- 代码位置面包屑
            -- https://nvimdev.github.io/lspsaga/breadcrumbs/
            symbol_in_winbar = {
                enable = true,
            },
        },
    },
}
