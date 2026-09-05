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
        config = function(_, opts)
            -- Attach blink.cmp capabilities to every server before it is enabled.
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
            })
            require("mason-lspconfig").setup(opts)
        end,
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
            "saghen/blink.cmp",
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
