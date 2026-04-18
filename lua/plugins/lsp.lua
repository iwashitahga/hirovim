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
      -- virtual_text truncates long messages on the code line, so we render
      -- them under the current line with virtual_lines instead. virt_lines
      -- extmarks do NOT honour 'wrap', so a long TS error would still run off
      -- the right edge of the window; wrap the message manually so each
      -- segment becomes its own virtual line.
      local function wrap_diagnostic(diagnostic)
        local win = vim.api.nvim_get_current_win()
        local gutter = vim.fn.getwininfo(win)[1].textoff or 0
        local width = vim.api.nvim_win_get_width(win) - gutter - 2
        if width < 30 then width = 30 end
        local out = {}
        for paragraph in vim.gsplit(diagnostic.message, "\n", { plain = true }) do
          while vim.fn.strdisplaywidth(paragraph) > width do
            local break_at = width
            for i = width, 1, -1 do
              if paragraph:sub(i, i):match("%s") then
                break_at = i
                break
              end
            end
            table.insert(out, paragraph:sub(1, break_at - 1))
            paragraph = paragraph:sub(break_at + 1)
          end
          table.insert(out, paragraph)
        end
        return table.concat(out, "\n")
      end
      vim.diagnostic.config {
        virtual_text = false,
        virtual_lines = { current_line = true, format = wrap_diagnostic },
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        jump = { float = true },
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
          -- Telescope pickers give us preview + incremental filtering for
          -- multi-result LSP queries. Start in normal mode for list browsing
          -- (references/definitions/...) and insert mode for symbol search.
          local tb = require("telescope.builtin")
          map("n", "gd", function() tb.lsp_definitions { initial_mode = "normal" } end, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", function() tb.lsp_references { initial_mode = "normal" } end, "References")
          map("n", "gi", function() tb.lsp_implementations { initial_mode = "normal" } end, "Implementation")
          map("n", "gy", function() tb.lsp_type_definitions { initial_mode = "normal" } end, "Type definition")
          map("n", "<leader>fs", tb.lsp_document_symbols, "Document symbols")
          map("n", "<leader>fS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "[d", function() vim.diagnostic.jump { count = -1 } end, "Prev diagnostic")
          map("n", "]d", function() vim.diagnostic.jump { count = 1 } end, "Next diagnostic")
          map("n", "[e", function()
            vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
          end, "Prev error")
          map("n", "]e", function()
            vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
          end, "Next error")
          map("n", "<leader>cd", vim.diagnostic.open_float, "Show line diagnostic")
          map("n", "<leader>xq", function()
            vim.diagnostic.setqflist { severity = { min = vim.diagnostic.severity.WARN } }
          end, "Diagnostics → quickfix")
        end,
      })
    end,
  },
}
