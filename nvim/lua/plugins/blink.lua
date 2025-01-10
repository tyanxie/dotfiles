return {
    {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = "rafamadriz/friendly-snippets",

        -- use a release tag to download pre-built binaries
        version = "*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 当前配置的常用键位
            -- <Tab> - 选择当前内容
            -- <CR> - 选择当前内容
            -- <C-space> - 查看文档内容
            -- <C-e> - 关闭选择列表
            -- <C-b> - 文档向上滑动
            -- <C-f> - 文档向下滑动
            keymap = {
                -- 默认使用 super-tab，即使用TAB进行补全
                preset = "super-tab",

                -- 回车键也优先用于补全
                ["<CR>"] = { "accept", "fallback" },
            },

            completion = {
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
                        -- 参考blink文档完善菜单栏绘制
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind_icon", "kind" },
                        },
                    },
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
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
        opts_extend = { "sources.default" },
    },
}
