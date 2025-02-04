return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
            -- set an empty statusline till lualine loads
            vim.o.statusline = " "
        else
            -- hide the statusline on the starter page
            vim.o.laststatus = 0
        end
    end,
    opts = function()
        local lualine_require = require("lualine_require")
        lualine_require.require = require

        local icons = require("util.icons")

        vim.o.laststatus = vim.g.lualine_laststatus

        return {
            options = {
                theme = "auto",
                section_separators = { left = "", right = "" }, -- 模块之间的分隔符
                component_separators = { left = "|", right = "|" }, -- 组件之间的分隔符
                globalstatus = vim.o.laststatus == 3, -- 全局状态栏模式时才启用
                disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
            },
            sections = {
                lualine_a = {
                    -- 通用模式信息
                    { "mode" },
                    -- 自定义模式信息
                    {
                        function()
                            local ok, hydra = pcall(require, "hydra.statusline")
                            if ok then
                                return hydra.get_name()
                            end
                            return ""
                        end,
                        cond = function()
                            local ok, hydra = pcall(require, "hydra.statusline")
                            return ok and hydra.is_active()
                        end,
                    },
                },
                lualine_b = { "branch" },
                lualine_c = {
                    {
                        "diagnostics",
                        symbols = {
                            error = icons.diagnostics.Error,
                            warn = icons.diagnostics.Warn,
                            info = icons.diagnostics.Info,
                            hint = icons.diagnostics.Hint,
                        },
                    },
                    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                    {
                        "filename",
                        file_status = true,
                        newfile_status = false,
                        path = 1,
                        shorting_target = 40,
                        symbols = {
                            modified = "[+]",
                            readonly = " 󰌾 ",
                            unnamed = "[No Name]",
                            newfile = "[New]",
                        },
                    },
                },
                lualine_x = {
                    Snacks.profiler.status(),
                    {
                        function()
                            return require("noice").api.status.command.get()
                        end,
                        cond = function()
                            return package.loaded["noice"] and require("noice").api.status.command.has()
                        end,
                        color = function()
                            return { fg = Snacks.util.color("Statement") }
                        end,
                    },
                    {
                        function()
                            return require("noice").api.status.mode.get()
                        end,
                        cond = function()
                            return package.loaded["noice"] and require("noice").api.status.mode.has()
                        end,
                        color = function()
                            return { fg = Snacks.util.color("Constant") }
                        end,
                    },
                    {
                        function()
                            return "  " .. require("dap").status()
                        end,
                        cond = function()
                            return package.loaded["dap"] and require("dap").status() ~= ""
                        end,
                        color = function()
                            return { fg = Snacks.util.color("Debug") }
                        end,
                    },
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = function()
                            return { fg = Snacks.util.color("Special") }
                        end,
                    },
                    {
                        "diff",
                        symbols = {
                            added = icons.git.added,
                            modified = icons.git.modified,
                            removed = icons.git.removed,
                        },
                        source = function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if gitsigns then
                                return {
                                    added = gitsigns.added,
                                    modified = gitsigns.changed,
                                    removed = gitsigns.removed,
                                }
                            end
                        end,
                    },
                },
                lualine_y = {
                    { "progress", separator = " ", padding = { left = 1, right = 0 } },
                    { "location", padding = { left = 0, right = 1 } },
                },
                lualine_z = {
                    function()
                        return " " .. os.date("%R")
                    end,
                },
            },
            extensions = { "neo-tree", "lazy", "fzf" },
        }
    end,
}
