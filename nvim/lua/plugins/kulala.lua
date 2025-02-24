-- 对于http后缀的文件定义为http文件类型
vim.filetype.add({
    extension = {
        ["http"] = "http",
    },
})

-- kulala.nvim 适用与neovim的最简http客户端界面插件
-- https://neovim.getkulala.net
return {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {
        global_keymaps = false, -- 关闭全局快捷键
    },
    keys = {
        -- 发送当前光标下或选中的请求
        {
            "<leader>Rs",
            function()
                require("kulala").run()
            end,
            mode = { "n", "v" },
            desc = "Send Request",
        },
        -- 仅在http或rest类型的文件中使用回车键发送选中的请求
        {
            "<CR>",
            function()
                require("kulala").run()
            end,
            mode = { "n", "v" },
            ft = { "http", "rest" },
            desc = "Send Request (http filetype)",
        },
        -- 打开kulala的ui界面
        {
            "<leader>Ro",
            function()
                require("kulala").open()
            end,
            desc = "Open Kulala",
        },
    },
}
