return {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = function()
        local fzf = require("fzf-lua")
        local config = fzf.config
        local actions = fzf.actions

        -- Quickfix
        config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
        config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
        config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
        config.defaults.keymap.fzf["ctrl-x"] = "jump"
        config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
        config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
        config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
        config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

        return {
            "default-title",
            fzf_colors = true,
            fzf_opts = {
                ["--no-scrollbar"] = true,
            },
            defaults = {
                formatter = "path.dirname_first",
            },
            winopts = {
                width = 0.9,
                height = 0.9,
                row = 0.5,
                col = 0.5,
                preview = {
                    scrollchars = { "┃", "" },
                },
            },
            files = {
                cwd_prompt = false,
                actions = {
                    ["alt-i"] = { actions.toggle_ignore },
                    ["alt-h"] = { actions.toggle_hidden },
                },
            },
            grep = {
                actions = {
                    ["alt-i"] = { actions.toggle_ignore },
                    ["alt-h"] = { actions.toggle_hidden },
                },
            },
            lsp = {
                symbols = {
                    symbol_hl = function(s)
                        return "TroubleIcon" .. s
                    end,
                    symbol_fmt = function(s)
                        return s:lower() .. "\t"
                    end,
                    child_prefix = false,
                },
                code_actions = {
                    previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
                },
            },
        }
    end,
    keys = {
        -- 快捷查找内容
        -- 全局搜索
        {
            "<leader>/",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "Grep",
        },
        -- 全局查找文件
        {
            "<leader><space>",
            function()
                require("fzf-lua").files()
            end,
            desc = "Find Files",
        },
        -- git
        -- 查看git commit列表
        {
            "<leader>gc",
            function()
                require("fzf-lua").git_commits()
            end,
            desc = "Git Log",
        },
        -- 查看git status变化列表
        {
            "<leader>gs",
            function()
                require("fzf-lua").git_status()
            end,
            desc = "Git Status",
        },
    },
}
