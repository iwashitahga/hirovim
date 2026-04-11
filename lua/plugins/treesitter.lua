-- nvim-treesitter `main` branch rewrite.
-- Requires Neovim 0.12+, tree-sitter-cli, and a C compiler.
-- The rewrite is installer + query distributor only; highlight / indent are
-- started per-buffer via Neovim's built-in `vim.treesitter` API below.
--
-- Upstream archived the repo, so pin to main explicitly.

local parsers = {
  "bash",
  "c",
  "diff",
  "fish",
  "go",
  "html",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- rewrite does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      -- Install missing parsers asynchronously on first launch.
      local have = {}
      for _, p in ipairs(require("nvim-treesitter").get_installed("parsers")) do
        have[p] = true
      end
      local missing = {}
      for _, p in ipairs(parsers) do
        if not have[p] then table.insert(missing, p) end
      end
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      -- Enable treesitter highlight + indent per filetype using the core API.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("hirovim_treesitter", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local ft = args.match
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not pcall(vim.treesitter.start, buf, lang) then return end
          -- indent (experimental but works well for most langs)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          -- treesitter-based folds
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
          vim.wo.foldenable = false
        end,
      })
    end,
  },
}
