-- Top bufferline (VSCode-style tabs for each open buffer).
--
-- Tab navigation:
--   <A-h> / <A-l>    previous / next tab (Option+h / Option+l on macOS)
--   <leader>bd        delete current buffer (in keymaps.lua)

return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      -- Close management
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Delete buffers right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers left" },
    },
    opts = {
      options = {
        mode = "buffers",
        numbers = "none",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " ", info = " " }
          local out = ""
          if diag.error then out = out .. icons.error .. diag.error .. " " end
          if diag.warning then out = out .. icons.warning .. diag.warning .. " " end
          return vim.trim(out)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
        always_show_bufferline = true,
        hover = { enabled = true, delay = 200, reveal = { "close" } },
      },
    },
  },
}
