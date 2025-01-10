return {
    -- use mason install shell checker and sh/bash language server
    {
        "williamboman/mason.nvim",
        opts = { ensure_installed = { "bash-language-server", "shellcheck" } },
    },
}
