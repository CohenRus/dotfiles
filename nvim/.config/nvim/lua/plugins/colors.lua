return {
  "RedsXDD/neopywal.nvim",
  name = "neopywal",
  lazy = false, -- Make sure it loads immediately on startup
  priority = 1000, -- Highest priority so colors load before UI plugins
  dependencies = {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      lazy = false,
    },
  },
  config = function()
    local neopywal = require("neopywal")

    neopywal.setup({
      transparent_background = true,
      -- Neopywal compiles the theme for speed.
      -- It will auto-detect when you run pywal16 and recompile!
    })

    vim.cmd.colorscheme("neopywal")

    -- Hybrid theme: neopywal (pywal) owns every UI group (statusline,
    -- float borders, folds, etc.), but code text uses Catppuccin Macchiato.
    --
    -- Capture Catppuccin's syntax groups, switch back to neopywal, then
    -- re-apply only the code groups on top.
    require("catppuccin").setup({ flavour = "macchiato" })
    vim.cmd.colorscheme("catppuccin-macchiato")

    local syntax = {}

    -- All treesitter `@...` groups (includes `@lsp.type.*` semantic tokens).
    -- `link = false` resolves link chains to concrete colors so we snapshot
    -- Catppuccin's final values, independent of neopywal's link targets.
    for _, name in ipairs(vim.fn.getcompletion("@", "highlight")) do
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      if next(hl) ~= nil then
        syntax[name] = hl
      end
    end

    -- Classic (non-treesitter) syntax groups, for filetypes without a parser.
    for _, name in ipairs({
      "Comment", "Constant", "String", "Character", "Number", "Boolean",
      "Float", "Identifier", "Function", "Statement", "Conditional",
      "Repeat", "Label", "Operator", "Keyword", "Exception", "PreProc",
      "Include", "Define", "Macro", "PreCondit", "Type", "StorageClass",
      "Structure", "Typedef", "Special", "SpecialChar", "Tag", "Delimiter",
      "SpecialComment", "Debug", "Underlined", "Ignore", "Error", "Todo",
    }) do
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      if next(hl) ~= nil then
        syntax[name] = hl
      end
    end

    -- Back to pywal UI, then layer Catppuccin code colors on top.
    vim.cmd.colorscheme("neopywal")
    for name, hl in pairs(syntax) do
      vim.api.nvim_set_hl(0, name, hl)
    end
  end,
}
