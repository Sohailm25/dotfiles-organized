return {
  -- Agentic.nvim (ACP-based AI chat)
  {
    "carlos-algms/agentic.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local current_provider = "claude-acp"
      local providers = {
        { display = "1. Claude", value = "claude-acp" },
        { display = "2. Codex", value = "codex-acp" },
        { display = "3. OpenCode", value = "opencode-acp" },
      }

      local function setup_agentic(provider)
        current_provider = provider
        require("agentic").setup({ provider = provider })
      end

      setup_agentic(current_provider)

      vim.keymap.set("n", "<leader>aa", function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        pickers
          .new({}, {
            prompt_title = "Select AI Provider",
            finder = finders.new_table({
              results = providers,
              entry_maker = function(entry)
                local marker = entry.value == current_provider and " (current)" or ""
                return {
                  value = entry.value,
                  display = entry.display .. marker,
                  ordinal = entry.display,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                  setup_agentic(selection.value)
                  require("agentic").toggle()
                end
              end)
              -- Number key shortcuts
              for i, p in ipairs(providers) do
                map("i", tostring(i), function()
                  actions.close(prompt_bufnr)
                  setup_agentic(p.value)
                  require("agentic").toggle()
                end)
                map("n", tostring(i), function()
                  actions.close(prompt_bufnr)
                  setup_agentic(p.value)
                  require("agentic").toggle()
                end)
              end
              return true
            end,
          })
          :find()
      end, { desc = "Select Provider & Toggle Agentic" })

      vim.keymap.set("n", "<leader>at", "<cmd>AgenticToggle<cr>", { desc = "Toggle Agentic Chat" })
      vim.keymap.set("n", "<leader>an", "<cmd>AgenticNew<cr>", { desc = "New Agentic Chat" })
    end,
  },

  -- Amp (Sourcegraph AI)
  {
    "sourcegraph/amp.nvim",
    branch = "main",
    lazy = false,
    opts = { auto_start = true, log_level = "info" },
  },

  -- Claude Code
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
    },
    config = function()
      require("claude-code").setup()
    end,
  },

  -- Codex
  {
    "kkrampis/codex.nvim",
    keys = {
      { "<leader>cx", function() require("codex").toggle() end, desc = "Toggle Codex", mode = { "n", "t" } },
    },
    opts = {
      keymaps = {
        toggle = nil,
        quit = "<C-q>",
      },
      border = "rounded",
      width = 0.8,
      height = 0.8,
      autoinstall = true,
      panel = false,
    },
  },

  -- Fix for snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = false },
      win = { enabled = true },
    },
  },

  -- Disable markdownlint for markdown files (using markdown for notes, not strict linting)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
  -- Comfy Line Numbers
  {
    "mluders/comfy-line-numbers.nvim",
    config = function()
      require("comfy-line-numbers").setup({
        labels = {
          "1",
          "2",
          "3",
          "4",
          "5",
          "11",
          "12",
          "13",
          "14",
          "15",
          "21",
          "22",
          "23",
          "24",
          "25",
          "31",
          "32",
          "33",
          "34",
          "35",
          "41",
          "42",
          "43",
          "44",
          "45",
          "51",
          "52",
          "53",
          "54",
          "55",
          "111",
          "112",
          "113",
          "114",
          "115",
          "121",
          "122",
          "123",
          "124",
          "125",
          "131",
          "132",
          "133",
          "134",
          "135",
          "141",
          "142",
          "143",
          "144",
          "145",
          "151",
          "152",
          "153",
          "154",
          "155",
          "211",
          "212",
          "213",
          "214",
          "215",
          "221",
          "222",
          "223",
          "224",
          "225",
          "231",
          "232",
          "233",
          "234",
          "235",
          "241",
          "242",
          "243",
          "244",
          "245",
          "251",
          "252",
          "253",
          "254",
          "255",
        },
        up_key = "k",
        down_key = "j",
        hidden_file_types = { "undotree" },
        hidden_buffer_types = { "terminal", "nofile" },
      })
    end,
  },

  -- Twilight
  {
    "folke/twilight.nvim",
    opts = {
      dimming = {
        alpha = 0.25,
        color = { "Normal", "#ffffff" },
        term_bg = "#000000",
        inactive = false,
      },
      context = 10,
      treesitter = true,
      expand = {
        "function",
        "method",
        "table",
        "if_statement",
      },
      exclude = {},
    },
  },
  -- Zen Mode
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        backdrop = 0.95,
        width = 120,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
          laststatus = 0,
        },
        twilight = { enabled = true }, -- This will auto-enable your Twilight plugin!
        gitsigns = { enabled = false },
        tmux = { enabled = false },
        todo = { enabled = false },
      },
    },
  },
  {

    "chomosuke/typst-preview.nvim",

    lazy = false, -- or ft = 'typst'

    version = "1.*",

    opts = {}, -- lazy.nvim will implic:itly calls `setup {}`

    follow_cursor = true,
  },

  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
        markdown_oxide = {},
        -- If you're using markdownlint through null-ls or none-ls
      },
    },
  },
}
