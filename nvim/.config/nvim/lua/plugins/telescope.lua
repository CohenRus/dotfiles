local builtin = require('telescope.builtin')

return {
    {
        "nvim-telescope/telescope.nvim",
        lazy = false,
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {defaults = {
            mappings = {
                i = {
                    ["<C-d>"] = require("telescope.actions").delete_buffer,
                },
                n = {
                    ["<C-d>"] = require("telescope.actions").delete_buffer,
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
            { "<leader>gf", builtin.git_files, desc = "Git Files" },
            { "<leader>g", builtin.live_grep, desc = "Grep String" },
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
