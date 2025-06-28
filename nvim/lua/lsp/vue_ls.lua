---@brief
---
--- https://github.com/vuejs/language-tools/tree/master/packages/language-server
---
--- The official language server for Vue
---

local function get_typescript_server_path(root_dir)
  local project_roots = vim.fs.find("node_modules", { path = root_dir, upward = true, limit = math.huge })
  for _, project_root in ipairs(project_roots) do
    local typescript_path = project_root .. "/typescript"
    local stat = vim.uv.fs_stat(typescript_path)
    if stat and stat.type == "directory" then
      return typescript_path .. "/lib"
    end
  end
  return ""
end

return {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  root_markers = { "package.json" },
  -- https://github.com/vuejs/language-tools/blob/v2/packages/language-server/lib/types.ts
  init_options = {
    typescript = {
      tsdk = "",
    },
  },
  before_init = function(_, config)
    if config.init_options and config.init_options.typescript and config.init_options.typescript.tsdk == "" then
      config.init_options.typescript.tsdk = get_typescript_server_path(config.root_dir)
    end
  end,
}
