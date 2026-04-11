-- Linter integration via nvim-lint.
-- Actual linter binaries are installed through mason-tool-installer
-- (see formatting.lua).

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("hirovim_lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })

      vim.keymap.set("n", "<leader>ll", function()
        lint.try_lint()
      end, { silent = true, desc = "Lint buffer now" })
    end,
  },
}
