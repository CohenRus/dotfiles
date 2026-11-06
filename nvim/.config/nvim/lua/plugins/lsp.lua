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
            handlers = {
                -- 1. Default handler for most servers
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
                
                -- 2. Custom handler specifically for clangd
                ["clangd"] = function()
                    require("lspconfig").clangd.setup({
                        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "arduino" },
                    })
                end,
            }
        },
        config = function(_, opts)
            -- Attach blink.cmp capabilities globally
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
            })
            
            -- This single setup call now automatically handles all installations and custom handlers
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
