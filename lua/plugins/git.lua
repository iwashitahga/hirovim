-- Git integration.
--
-- gitsigns     : inline hunk UI (signs, navigation, stage/reset/preview, blame)
-- diffview.nvim: full-window diff browser and file history viewer
-- octo.nvim    : GitHub PRs/issues/reviews via the gh CLI
--
-- Keymap prefix: <leader>g* (local git)  /  <leader>p* (GitHub PR review)

return {
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
      current_line_blame = false, -- start off, toggled by <leader>gB
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 100,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> — <summary>",
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Navigation between hunks
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")

        -- Actions
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff against HEAD~")
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diffview: open (working tree vs HEAD)" },
      { "<leader>gV", "<cmd>DiffviewClose<CR>", desc = "Diffview: close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: repo history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: current file history" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 35 },
      },
    },
  },

  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>go", "<cmd>Octo<CR>", desc = "Octo: menu" },
      { "<leader>gI", "<cmd>Octo issue list<CR>", desc = "Octo: issue list" },

      -- PR review lives under its own <leader>p prefix.
      -- `review start` / `resume` resolve the PR from the current buffer OR the
      -- checked-out branch, so <leader>po then <leader>pv is the usual path.
      { "<leader>pl", "<cmd>Octo pr list<CR>", desc = "PR: list" },
      -- Cross-repo. `Octo pr search` is repo-scoped, so the top-level
      -- `Octo search` (GitHub search syntax) is what spans repositories.
      --
      -- `involves:@me -author:@me` is wider than `review-requested:@me`: it also
      -- catches PRs commented on or mentioned in, minus one's own. Reviews often
      -- continue past the point where the request is cleared, so this keeps them.
      {
        "<leader>pR",
        "<cmd>Octo search is:pr is:open involves:@me -author:@me sort:updated-desc<CR>",
        desc = "PR: involves me, not mine",
      },
      { "<leader>po", "<cmd>Octo pr checkout<CR>", desc = "PR: checkout (picker if not in a PR buffer)" },
      { "<leader>pD", "<cmd>Octo pr diff<CR>", desc = "PR: diff" },
      { "<leader>pb", "<cmd>Octo pr browser<CR>", desc = "PR: open in browser" },

      { "<leader>pv", "<cmd>Octo review start<CR>", desc = "Review: start" },
      { "<leader>pr", "<cmd>Octo review resume<CR>", desc = "Review: resume pending" },
      { "<leader>ps", "<cmd>Octo review submit<CR>", desc = "Review: submit" },
      { "<leader>pd", "<cmd>Octo review discard<CR>", desc = "Review: discard" },
      { "<leader>pc", "<cmd>Octo review comments<CR>", desc = "Review: pending comments" },
      { "<leader>pt", "<cmd>Octo review thread<CR>", desc = "Review: threads" },
      { "<leader>pq", "<cmd>Octo review close<CR>", desc = "Review: close tab" },
    },
    opts = {
      enable_builtin = true,
      picker = "telescope",
      use_local_fs = true,
    },
  },
}
