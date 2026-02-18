return {
  -- LSP for Cargo.toml
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  -- rust-analyzer 与 rust-tools.nvim 的增强版插件，提供 rust 的 LSP 初始化
  {
    "mrcjkb/rustaceanvim",
    version = "^8",
    lazy = false,
  },
}
