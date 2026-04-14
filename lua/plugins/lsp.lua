-- LSP setup using the Neovim 0.11+ `vim.lsp.config` / `vim.lsp.enable` API.
-- nvim-lspconfig is still installed because it ships the default server
-- configs (cmd, filetypes, root_dir, ...) that get registered via
-- `vim.lsp.config` when the plugin is loaded.

local servers = { "lua_ls", "ts_ls", "pyright", "terraformls" }

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
      -- Prefer per-module markers over .git so terraform-ls treats each
      -- env directory (env/prod, env/stg, ...) in a monorepo as its own
      -- module. Without this, root_dir collapses to the repo root and
      -- var/local completion across modules gets confused.
      vim.lsp.config("terraformls", {
        -- Resolve root per module (env/prod, env/stg, _shared/modules/*).
        -- Prefer init markers, fall back to any .tf sibling, then the file's
        -- own directory so pre-init modules still attach correctly.
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local start = vim.fs.dirname(fname)
          local hit = vim.fs.find(
            { ".terraform.lock.hcl", ".terraform", "terragrunt.hcl" },
            { path = start, upward = true, stop = vim.loop.os_homedir() }
          )[1]
          if hit then
            on_dir(vim.fs.dirname(hit))
            return
          end
          -- No init marker: use the nearest ancestor that contains any .tf file.
          local tf = vim.fs.find(
            function(name) return name:match("%.tf$") or name:match("%.tf%.json$") end,
            { path = start, upward = true, type = "file", stop = vim.loop.os_homedir() }
          )[1]
          on_dir(tf and vim.fs.dirname(tf) or start)
        end,
      })

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
