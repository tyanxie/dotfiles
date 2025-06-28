---@brief
---
--- https://github.com/bash-lsp/bash-language-server
---
--- `bash-language-server` can be installed via `npm`:
--- ```sh
--- npm i -g bash-language-server
--- ```
---

local mod_cache = nil

---@param fname string
---@return string?
local function get_root(fname)
  if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
    local clients = vim.lsp.get_clients({ name = "gopls" })
    if #clients > 0 then
      return clients[#clients].config.root_dir
    end
  end
  return vim.fs.root(fname, "go.work") or vim.fs.root(fname, "go.mod") or vim.fs.root(fname, ".git")
end

return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    -- see: https://github.com/neovim/nvim-lspconfig/issues/804
    if mod_cache then
      on_dir(get_root(fname))
      return
    end
    local cmd = { "go", "env", "GOMODCACHE" }
    vim.system(cmd, { text = true }, function(output)
      if output.code == 0 then
        if output.stdout then
          mod_cache = vim.trim(output.stdout)
        end
        on_dir(get_root(fname))
      else
        vim.schedule(function()
          vim.notify(("[gopls] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr))
        end)
      end
    end)
  end,
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
}
