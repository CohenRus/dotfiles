return {
  "RedsXDD/neopywal.nvim",
  name = "neopywal",
  lazy = false, -- Make sure it loads immediately on startup
  priority = 1000, -- Highest priority so colors load before UI plugins
  config = function()
    local neopywal = require("neopywal")
    
    neopywal.setup({
      transparent_background = true,
      -- Neopywal compiles the theme for speed. 
      -- It will auto-detect when you run pywal16 and recompile!
    })
    
    -- Set the colorscheme
    vim.cmd.colorscheme("neopywal")
  end,
}
