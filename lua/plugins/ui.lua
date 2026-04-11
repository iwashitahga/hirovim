return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "storm", transparent = false },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
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
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
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
        [[ █████  ███████ ████████ ██████   ██████ ]],
        [[██   ██ ██         ██    ██   ██ ██    ██]],
        [[███████ ███████    ██    ██████  ██    ██]],
        [[██   ██      ██    ██    ██   ██ ██    ██]],
        [[██   ██ ███████    ██    ██   ██  ██████ ]],
        [[]],
        [[███    ██ ██    ██ ██ ███    ███]],
        [[████   ██ ██    ██ ██ ████  ████]],
        [[██ ██  ██ ██    ██ ██ ██ ████ ██]],
        [[██  ██ ██  ██  ██  ██ ██  ██  ██]],
        [[██   ████   ████   ██ ██      ██]],
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
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
