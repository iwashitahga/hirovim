-- flash.nvim: 2-char jump across the visible window.
--
-- Normal-mode `s` is reserved for vim-sandwich (`sa`/`sd`/`sr`), so flash
-- jump is bound to `<leader>s` in normal mode. In visual and operator-pending
-- mode `s` still triggers flash, so `sa<motion>` can use a flash label as
-- the motion target.

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
      { "<leader>s", mode = "n", function() require("flash").jump() end, desc = "Flash" },
      { "s", mode = { "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
