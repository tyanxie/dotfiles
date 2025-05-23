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

  -- 启用lsp
  vim.lsp.enable(server)
  -- 配置lsp
  vim.lsp.config(server, opts)
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
            Snacks.picker.lsp_definitions()
          end, { desc = "Goto Definition" })
          vim.keymap.set("n", "gr", function()
            Snacks.picker.lsp_references()
          end, { desc = "References", nowait = true })
          vim.keymap.set("n", "gi", function()
            Snacks.picker.lsp_implementations()
          end, { desc = "Goto Implementation" })
          vim.keymap.set("n", "gy", function()
            Snacks.picker.lsp_type_definitions()
          end, { desc = "Goto T[y]pe Definition" })
          vim.keymap.set("n", "gD", function()
            Snacks.picker.lsp_declarations()
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
              assignVariableTypes = false,
              compositeLiteralFields = false,
              compositeLiteralTypes = false,
              constantValues = true,
              functionTypeParameters = false,
              parameterNames = false,
              rangeVariableTypes = false,
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
            staticcheck = false, -- 是否使用staticcheck进行代码检查
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
          new_config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
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

      -- javascript/typescript
      setup("ts_ls", {
        filetypes = { "javascript", "typescript", "vue" },
        init_options = {
          plugins = {
            -- 支持vue-typescript相关的配置，参考lspconfig官方内容进行配置
            -- 主要逻辑为从mason的安装目录中获取vue的typescript插件目录
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#vue-support
            {
              name = "@vue/typescript-plugin",
              location = vim.fn.stdpath("data")
                .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
              languages = { "javascript", "typescript", "vue" },
            },
          },
        },
      })

      -- vue
      setup("vue_ls", {})

      -- c/c++
      setup("clangd", {
        capabilities = {
          offsetEncoding = "utf-8",
        },
        cmd = {
          "clangd",
          "--background-index", -- 启用后台索引功能
          "--clang-tidy", -- 启用clang-tidy的代码格式检查和静态分析
          "--header-insertion=iwyu", -- 头文件插入策略，iwyu(Include What You Use)-只插入当前文件中实际使用的头文件
          "--completion-style=detailed", -- 代码补全的样式，detail-详细模式
          "--function-arg-placeholders", -- 选择函数补全项时，自动插入参数占位符
          "--query-driver=/usr/bin/clang++,/usr/bin/g++,/usr/bin/c++", -- 指定用于查询编译器驱动程序的路径列表
        },
        -- 强制配置filetypes，关闭proto支持
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      })

      -- python
      setup("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "off", -- 关闭类型检查，否则大部分工程都会有大量的错误提示
            },
          },
        },
      })

      -- cmake
      setup("cmake", {})
    end,
  },

  -- IDE风格的winbar（顶部面包屑）
  {
    "Bekaboo/dropbar.nvim",
    event = "LspAttach",
    opts = {},
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick symbols in winbar",
      },
    },
  },
}
