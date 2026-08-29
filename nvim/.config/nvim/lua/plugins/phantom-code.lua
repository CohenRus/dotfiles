return {
  'cohenrus/phantom-code.nvim',
  branch = "main",
  event = { 'BufNewFile', 'BufReadPre' },
  config = function()

  require('phantom-code').setup({
    provider = 'openai_compatible',

    context_window = 4096,

    context_ratio = 0.85,

    request_timeout = 15,

    notify = 'warn',

    -- curl_extra_args = { '-u', 'cohen:nyfxeM-8cenfa-zogwir' },

    -- LSP diagnostics near anchor (cursor for inline, selection start for Expand); injected into chat/FIM templates.
    diagnostics = {
      enable = true,
      line_radius = 10,
      min_severity = vim.diagnostic.severity.HINT,
      max_chars = 1024,
    },

    inline = {
      provider = 'openai_fim_compatible',

      -- Max lines per ghost-text item; nil = unlimited (virtual text only).
      max_lines = nil,

      -- Min ms between inline requests; 0 = no throttle.
      throttle = 500,

      -- Ms to wait after typing before request; 0 = no debounce.
      debounce = 200,

      -- After the model returns: trim the end of a candidate when the longest overlap between the
      -- completion suffix and the text after the cursor is at least this many characters (avoids
      -- repeating code already below the cursor). 0 disables.
      after_cursor_filter_length = 1,

      -- Same overlap idea for the start of the candidate vs text before the cursor; default 2 so
      -- only a strong echo of the cursor area is stripped. 0 disables.
      before_cursor_filter_length = 1,

      virtualtext = {
        -- Filetypes for auto trigger; '*' = all; {} = manual only.
        auto_trigger_ft = { '*' },
        -- Excluded filetypes when using '*'.
        auto_trigger_ignore_ft = {
          'gitcommit',
          'gitrebase',
          'help',
          'text',
          'log',
          'asciidoc',
          'tex',
          'mail',
        },
        keymap = {
          accept = '<C-y>',
          dismiss = '<C-n>',
        },

        -- If false, hide ghost text while blink menu is open.
        show_on_completion_menu = false,
      },

      blink = {
        enable_auto_complete = false,
      },
    },

    expand = {
      enable = true,

      provider = 'openai_compatible',

      context_window = 16000,
      -- Cap output tokens for this request; nil = provider default.
      max_tokens = 4096,

      prompt_ui = 'float',

      ui = { prompt_height = 10, prompt_width = 72, ask_height = 16, ask_width = 80 },

      keymap = {
        invoke = '<leader>ae',
        ask = '<leader>aa',

        accept = '<leader>ay',
        dismiss = '<leader>an',

        revise = '<leader>ar',

        focus_window = '<leader>aw', -- jump into / out of expand floats
        toggle_window = '<leader>at',
      },
    },

    provider_options = {
      openai_compatible = {
        api_key = function() return 'none' end,
        name = 'Ollama',
        end_point = 'https://home.cohdoo.com/ai/v1/chat/completions',
        model = 'qwen3-coder:30b-a3b-q4_K_M',
        stream = true,
        transform = {
          function(data)
            data.headers['Authorization'] = nil  -- remove Bearer header
            return data
          end,
        },
      },
      openai_fim_compatible = {
        api_key = function() return 'none' end,
        name = 'Ollama',
        end_point = 'https://home.cohdoo.com/ai/v1/completions',
        model = 'qwen2.5-coder:14b',
        stream = true,
        optional = {
          max_tokens = 52,
        },
        transform = {
          function(data)
            data.headers['Authorization'] = nil  -- remove Bearer header
            return data
          end,
        },
      },
    },
  })
  end;
}
