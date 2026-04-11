-- flash.nvim: 2-char jump across the visible window.
--
-- Press `s` + 2 characters → every matching position gets a label; press
-- the label letter to jump. Works in normal, visual, and operator-pending
-- mode (so `ys<label>...` with vim-sandwich works too).

return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false }, -- leave `/` and `?` alone
        char = { enabled = true }, -- enhance f/F/t/T with flash labels
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
