-- 通用初始化lsp函数
local function setup(server)
  -- 启用lsp
  vim.lsp.enable(server)

  -- 获取配置模块，如果获取失败则直接返回，否则开始配置lsp
  local ok, opts = pcall(require, "lsp." .. server)
  if not ok then
    return
  end

  -- 如果disabled为true则直接返回
  if opts.disabled == true then
    vim.notify("lsp server [" .. server .. "] is disabled")
    return
  end

  -- 生成capabilities，用于让lsp服务器知道当前支持哪些lsp能力
  local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(), -- neovim自带支持的lsp能力
    opts.capabilities or {} -- opts中配置的lsp能力
  )

  -- 赋值新的capabilities配置选项
  opts = vim.tbl_deep_extend("force", {
    capabilities = vim.deepcopy(capabilities),
  }, opts)

  -- 配置lsp
  vim.lsp.config(server, opts)
end

-- 配置所有lsp --

-- lua
setup("lua_ls")

-- golang
setup("gopls")

-- shell
setup("bashls")

-- yaml
setup("yamlls")

-- toml
setup("taplo")

-- json
setup("jsonls")

-- protobuf
setup("protols")

-- markdown
setup("marksman")

-- html
setup("html")

-- css
setup("cssls")

-- javascript/typescript/vue
setup("vtsls")

-- vue
setup("vue_ls")

-- c/c++
setup("clangd")

-- python
setup("basedpyright")

-- cmake
setup("cmake")

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
