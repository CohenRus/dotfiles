return {
    "lewis6991/gitsigns.nvim",
    event = {"BufReadPost", "BufNewFile"},
    config = function ()
        require("gitsigns").setup({
            signs_staged_enable = true,
            signcolumn = true,
            current_line_blame = true,
        })
    end
}
