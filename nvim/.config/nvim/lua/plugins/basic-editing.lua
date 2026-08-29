return {
    {
        "m4xshen/autoclose.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {}
    },
    {
        "kylechui/nvim-surround",
        event = { "BufReadPost", "BufNewFile" },
        opts = {}
    },
    {
        "tpope/vim-commentary",
        event = { "BufReadPost", "BufNewFile" },
    }
}
