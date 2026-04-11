-- LSP setup using the Neovim 0.11+ `vim.lsp.config` / `vim.lsp.enable` API.
-- nvim-lspconfig is still installed because it ships the default server
-- configs (cmd, filetypes, root_dir, ...) that get registered via
-- `vim.lsp.config` when the plugin is loaded.

local servers = { "lua_ls", "ts_ls", "pyright" }

return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = servers,
      automatic_enable = false, -- we call vim.lsp.enable() ourselves below
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      -- Diagnostics UI
      vim.diagnostic.config {
        virtual_text = { prefix = "●" },
        severity_sort = true,
        float = { border = "rounded" },
      }

      -- Global defaults applied to every server via wildcard config.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Per-server overrides.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Enable the servers. `vim.lsp.enable` attaches them to matching
      -- buffers automatically; no need to iterate here.
      vim.lsp.enable(servers)

      -- The FileType event for the current buffer already fired before this
      -- plugin was lazy-loaded, so re-trigger it to attach servers to it.
      vim.schedule(function() vim.cmd "silent! do FileType" end)

      -- Buffer-local keymaps on attach.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("hirovim_lsp_attach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gi", vim.lsp.buf.implementation, "Implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "[d", function() vim.diagnostic.jump { count = -1 } end, "Prev diagnostic")
          map("n", "]d", function() vim.diagnostic.jump { count = 1 } end, "Next diagnostic")
        end,
      })
    end,
  },
}
