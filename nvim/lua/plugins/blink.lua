return {
    {
        "saghen/blink.cmp",
        disable = false,
        event = "InsertEnter",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "saghen/blink.compat",
            "xzbdmw/colorful-menu.nvim",
        },
        version = "*", -- 指定为`*`以固定使用最新稳定版本
        opts = {
            -- 当前配置的常用键位
            -- <Tab> - 选择当前内容
            -- <CR> - 选择当前内容
            -- <C-space> - 查看文档内容
            -- <C-e> - 关闭选择列表
            -- <Up> / <C-p> / <C-k> - 选择上一个目标
            -- <Down> / <C-n> / <C-j> - 选择下一个目标
            -- <C-b> - 文档向上滑动
            -- <C-f> - 文档向下滑动
            keymap = {
                -- 默认使用super-tab，使用TAB进行补全
                preset = "super-tab",
                -- 回车键优先用于补全
                ["<CR>"] = { "accept", "fallback" },
                -- Ctrl-j和Ctrl-k优先用于上下选择目标
                ["<C-j>"] = { "select_next", "fallback_to_mappings" },
                ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
            },
            completion = {
                accept = {
                    -- 自动添加括号
                    auto_brackets = {
                        enabled = true,
                    },
                },
                list = {
                    selection = {
                        -- 自动选择列表中的第一项
                        -- keymap使用super-tab时推荐配置该选项
                        -- https://cmp.saghen.dev/configuration/keymap.html#presets
                        preselect = function(_)
                            return not require("blink.cmp").snippet_active({ direction = 1 })
                        end,
                    },
                },
                -- 菜单栏绘制
                menu = {
                    scrollbar = false,
                    border = {
                        { "󱐋", "WarningMsg" },
                        "─",
                        "╮",
                        "│",
                        "╯",
                        "─",
                        "╰",
                        "│",
                    },
                    draw = {
                        -- 使用treesitter对菜单栏的代码进行上色提示
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon" },
                            -- 不配置label_description
                            -- 因为colorful-menu插件已经将label和label_description组合在一起了
                            { "label", gap = 1 },
                        },
                        -- 绘制组件配置
                        components = {
                            -- 类型icon配置
                            kind_icon = {
                                -- 使用mini-icons绘制颜色
                                highlight = function(ctx)
                                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                    return hl
                                end,
                            },
                            -- 类型配置
                            kind = {
                                -- 使用mini-icons绘制颜色
                                highlight = function(ctx)
                                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                    return hl
                                end,
                            },
                            -- 标签配置，使用colorful-menu增强文本和颜色
                            label = {
                                text = function(ctx)
                                    return require("colorful-menu").blink_components_text(ctx)
                                end,
                                highlight = function(ctx)
                                    return require("colorful-menu").blink_components_highlight(ctx)
                                end,
                            },
                        },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                    window = {
                        border = {
                            { "", "DiagnosticHint" },
                            "─",
                            "╮",
                            "│",
                            "╯",
                            "─",
                            "╰",
                            "│",
                        },
                    },
                },
                ghost_text = {
                    -- 不显示预览文字
                    enabled = false,
                },
            },
            appearance = {
                -- 告诉blink当前终端的字体类型，用于调整间距以确保图标对齐
                -- mono - Nerd Font Mono
                -- normal - Nerd Font
                nerd_font_variant = "mono",
                -- 类型icon列表
                kind_icons = require("util.icons").kinds,
            },
            sources = {
                -- 要启用的代码提示数据源列表
                default = { "lsp", "path", "snippets", "buffer" },
            },
            -- cmdline模式补全
            cmdline = {
                enabled = false,
            },
        },
        opts_extend = {
            "sources.default",
            "sources.completion.enabled_providers",
            "sources.compat",
        },
    },

    -- 使用colorful-menu完善blink的菜单栏绘制
    {
        "xzbdmw/colorful-menu.nvim",
        opts = {},
    },
}
