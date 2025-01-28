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
        -- use a release tag to download pre-built binaries
        version = "*",
        opts = {
            -- 当前配置的常用键位
            -- <Tab> - 选择当前内容
            -- <CR> - 选择当前内容
            -- <C-space> - 查看文档内容
            -- <C-e> - 关闭选择列表
            -- <C-b> - 文档向上滑动
            -- <C-f> - 文档向下滑动
            keymap = {
                -- 默认使用super-tab，使用TAB进行补全
                preset = "super-tab",
                -- 回车键优先用于补全
                ["<CR>"] = { "accept", "fallback" },
            },
            completion = {
                accept = {
                    -- experimental auto-brackets support
                    auto_brackets = {
                        enabled = true,
                    },
                },
                list = {
                    selection = {
                        -- keymap使用super-tab时推荐配置该选项
                        -- https://cmp.saghen.dev/configuration/keymap.html#presets
                        preselect = function(_)
                            return not require("blink.cmp").snippet_active({ direction = 1 })
                        end,
                    },
                },
                -- 菜单栏绘制
                menu = {
                    draw = {
                        -- 使用treesitter对菜单栏的代码进行上色提示
                        treesitter = { "lsp" },
                        -- We don't need label_description now because label and label_description are already
                        -- combined together in label by colorful-menu.nvim.
                        columns = {
                            { "kind_icon" },
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
                },
                ghost_text = {
                    -- 不显示预览文字
                    enabled = false,
                },
            },
            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = false,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
                -- 类型icon列表
                kind_icons = require("util.icons").kinds,
            },
            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
                -- 将cmdline选项设置为空table，以禁用cmdline的补全提示
                cmdline = {},
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
        opts = {
            -- If provided, the plugin truncates the final displayed text to
            -- this width (measured in display cells). Any highlights that extend
            -- beyond the truncation point are ignored. When set to a float
            -- between 0 and 1, it'll be treated as percentage of the width of
            -- the window: math.floor(max_width * vim.api.nvim_win_get_width(0))
            -- Default 60.
            max_width = 60,
            ls = {
                lua_ls = {
                    -- Maybe you want to dim arguments a bit.
                    arguments_hl = "@comment",
                },
                gopls = {
                    -- By default, we render variable/function's type in the right most side,
                    -- to make them not to crowd together with the original label.

                    -- when true:
                    -- foo             *Foo
                    -- ast         "go/ast"

                    -- when false:
                    -- foo *Foo
                    -- ast "go/ast"
                    align_type_to_right = true,
                    -- When true, label for field and variable will format like "foo: Foo"
                    -- instead of go's original syntax "foo Foo".
                    add_colon_before_type = false,
                },
            },
        },
    },
}
