vim.opt.guicursor = ""

-- Enable autoread
vim.opt.autoread = true

-- Auto-check for file changes when focus is gained or buffer entered
vim.api.nvim_create_autocmd({"FocusGained", "TermLeave", "BufEnter", "WinEnter", "CursorHold", "CursorHoldI"}, {
  pattern = "*",
  command = "checktime",
})

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 20
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.diagnostic.config({
  virtual_text = true,
  signs = false,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})
