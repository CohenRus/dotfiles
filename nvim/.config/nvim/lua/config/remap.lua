-- exit insert mode with jj  
vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("n", "<leader>gh", ":Gitsigns reset_hunk<CR>")

--clear the highlighed searching
vim.keymap.set({ "n", "v" }, "<leader>nh", ":noh<CR>")

--toggle line wrapping
vim.keymap.set({ "n", "v" }, "<leader>tw", ":set wrap!<CR>")

-- when selected lines in visual mode, can move up/down with shift jk 
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- when appending lines, keep cursor below
vim.keymap.set("n", "J", "mzJ`z")

-- when moving around, cursor gets centered in screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- space p pastes and keys the buffer to content
vim.keymap.set("x", "<leader>p", "\"_dP")
-- same thing for deleting keeping the buffer as it was
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

--<leader>y yanks to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y")
--copy entire buffer
vim.keymap.set({ "n"}, "<leader>ya", ":%y+<CR>")

vim.keymap.set("i", "<C-c>", "<Esc>")
