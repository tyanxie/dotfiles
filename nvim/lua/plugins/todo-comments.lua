return {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
        {
            "]t",
            function()
                require("todo-comments").jump_next()
            end,
            desc = "Next Todo Comment",
        },
        {
            "[t",
            function()
                require("todo-comments").jump_prev()
            end,
            desc = "Previous Todo Comment",
        },
        { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
        {
            "<leader>xT",
            "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
            desc = "Todo/Fix/Fixme (Trouble)",
        },
        {
            "<leader>st",
            function()
                require("todo-comments.fzf").todo()
            end,
            desc = "Todo",
        },
        {
            "<leader>sT",
            function()
                require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } })
            end,
            desc = "Todo/Fix/Fixme",
        },
    },
}
