return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
      -- 需要预安装的解析器
      local parsers = {
        "bash",
        "c",
        "cpp",
        "diff",
        "html",
        "css",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "json5",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "toml",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "gotmpl",
        "proto",
        "vue",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "ssh_config",
        "ron",
        "http",
        "cmake",
        "rust",
        "ron",
      }

      -- 启动后直接安装预安装解析器
      require("nvim-treesitter").install(parsers)

      -- 打开文件后执行加载treesitter
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          -- 校验treesitter是否支持
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          -- 校验解析器是否存在
          if not vim.treesitter.language.add(language) then
            return
          end

          -- 启动treesitter特性，如语法高亮等
          vim.treesitter.start(buf, language)

          -- 启用基于treesitter的缩进
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          -- 启用基于treesitter的折叠
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
      },
    },
    keys = {
      {
        "]f",
        mode = { "n", "x", "o" },
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
        end,
        desc = "Go to next function start",
      },
      {
        "[f",
        mode = { "n", "x", "o" },
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end,
        desc = "Go to previous function start",
      },
    },
  },

  -- 将当前函数的声明显示在编辑器最顶部
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = { mode = "cursor", max_lines = 3 },
  },

  -- 使用treesitter自动合并html标签，同时提供修改标签名称时同步修改对应的开/闭标签
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
  },
}
