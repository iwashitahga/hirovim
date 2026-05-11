return {
  -- vim-sandwich (ported from previous config)
  -- Loaded eagerly so its `<Plug>` mappings (sa/sd/sr/s) are installed before
  -- any buffer keystroke; lazy event-loading raced flash.nvim's normal-mode
  -- mapping for `s` and left `sa` falling through to vim's builtin substitute.
  {
    "machakann/vim-sandwich",
    lazy = false,
  },

  -- Autopairs with a tex/latex $...$ rule (ported from previous config)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({ check_ts = true })
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")
      npairs.add_rules({
        Rule("$", "$", { "tex", "latex" })
          :with_pair(cond.not_after_regex("%%"))
          :with_pair(cond.not_before_regex("xxx", 3))
          :with_move(cond.none())
          :with_del(cond.not_after_regex("xx"))
          :with_cr(cond.none()),
      })
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Which-key for discoverability
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
