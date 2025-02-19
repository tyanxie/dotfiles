return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "<leader>y",
            "<cmd>Yazi cwd<cr>",
            desc = "Open yazi in nvim's working directory",
        },
        {
            "<leader>Y",
            "<cmd>Yazi<cr>",
            mode = { "n", "v" },
            desc = "Open yazi at the current file",
        },
    },
}
