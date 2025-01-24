return {
    {
        "ray-x/go.nvim",
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        -- build = ':lua require("go.install").update_all_sync()',
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
    },
}
