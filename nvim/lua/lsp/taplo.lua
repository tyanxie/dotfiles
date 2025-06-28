---@brief
---
--- https://taplo.tamasfe.dev/cli/usage/language-server.html
---
--- Language server for Taplo, a TOML toolkit.
---

return {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { ".taplo.toml", "taplo.toml", ".git" },
}
