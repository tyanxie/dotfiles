---@brief
---
--- https://github.com/yioneko/vtsls
---
--- To configure a TypeScript project, add a
--- [`tsconfig.json`](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html)
--- or [`jsconfig.json`](https://code.visualstudio.com/docs/languages/jsconfig) to
--- the root of your project.
---

return {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue", -- 执行filetypes中必须有vue，否则vue文件中vtsls无法启用
  },
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          -- 支持vue-typescript相关的配置，参考lspconfig官方内容进行配置
          -- 主要逻辑为从mason的安装目录中获取vue的typescript插件目录
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#vue-support
          {
            name = "@vue/typescript-plugin",
            location = vim.fn.stdpath("data")
              .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
            languages = { "javascript", "typescript", "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
}
