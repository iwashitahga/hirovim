return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "day",
      light_style = "day",
      transparent = true,
      styles = {
        sidebars = "transparent",
        -- Floats keep their own background so `winblend` has something
        -- to blend against.
        floats = "normal",
      },
      on_highlights = function(hl, c)
        -- Keep line numbers / signs readable on a transparent background.
        hl.LineNr = { fg = c.fg_gutter }
        hl.CursorLineNr = { fg = c.orange, bold = true }
        hl.SignColumn = { bg = "NONE" }
        -- Keep float borders clearly visible.
        hl.FloatBorder = { fg = c.blue, bg = c.bg_float }
      end,
    },
    config = function(_, opts)
      vim.o.background = "light"
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-day")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = "",
        component_separators = "",
      },
    },
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[██   ██ ██ ██████   ██████ ]],
        [[██   ██ ██ ██   ██ ██    ██]],
        [[███████ ██ ██████  ██    ██]],
        [[██   ██ ██ ██   ██ ██    ██]],
        [[██   ██ ██ ██   ██  ██████ ]],
        [[]],
        [[███    ██ ██    ██ ██ ███    ███]],
        [[████   ██ ██    ██ ██ ████  ████]],
        [[██ ██  ██ ██    ██ ██ ██ ████ ██]],
        [[██  ██ ██  ██  ██  ██ ██  ██  ██]],
        [[██   ████   ████   ██ ██      ██]],
      }
      dashboard.section.buttons.val = {
        dashboard.button(
          "f",
          "  Find file",
          ":lua require('telescope.builtin').find_files({ initial_mode = 'normal' })<CR>"
        ),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live grep", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("l", "  Lazy", "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }
      alpha.setup(dashboard.opts)
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
}
