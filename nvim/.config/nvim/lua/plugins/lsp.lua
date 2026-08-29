return {
    {
        "mason-org/mason.nvim",
        event = { "BufNewFile", "BufReadPre" },
        cmd = "Mason",
        opts = {},
    },
    {
        "mason-org/mason-lspconfig.nvim",
        event = { "BufNewFile", "BufReadPre" },
        opts = {
            ensure_installed = { "lua_ls", "clangd", "pyright", "ts_ls", "cssls", "css_variables", "html", "bashls", "jdtls" },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufNewFile", "BufReadPre" },
        keys = {
            {"K", vim.lsp.buf.hover},
            {"gd", vim.lsp.buf.definition},
            {"<leader>ca", vim.lsp.buf.code_action},
            {"<leader>e", vim.diagnostic.open_float}
        },
    },
}
