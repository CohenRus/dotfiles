return {
    {
        "nvim-telescope/telescope.nvim",
        lazy = false,
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {defaults = {
            mappings = {
                i = {
                    ["<C-d>"] = "delete_buffer",
                },
                n = {
                    ["<C-d>"] = "delete_buffer",
                }
            },
            pickers = {
                find_files = {
                    hidden = true
                }
            }
        }},
        keys = {
            { "<leader>f", ":Telescope find_files<CR>", desc = "Find Files" },
            { "<leader>gf", function() require("telescope.builtin").git_files() end, desc = "Git Files" },
            { "<leader>g", function() require("telescope.builtin").live_grep() end, desc = "Grep String" },
            { "<leader>b", ":Telescope buffers<CR>"}
        }
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup {
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {
                            -- even more opts
                        }

                    }
                }
            }
            require("telescope").load_extension("ui-select")
        end,
    }
}
