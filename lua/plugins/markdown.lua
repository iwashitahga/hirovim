return {
  -- Browser preview for markdown, including ```mermaid blocks.
  -- In-terminal image rendering doesn't survive herdr, so preview in the browser instead.
  -- The build step downloads a prebuilt binary, so no yarn is needed.
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    build = function(plugin)
      -- ft-lazy loading leaves the autoload function off the rtp at build time.
      require("lazy").load({ plugins = { plugin.name } })
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "light"
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview (mermaid)" },
    },
  },
}
