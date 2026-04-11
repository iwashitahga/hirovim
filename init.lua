-- hirovim entry point.
-- Keep this file small; everything else lives under lua/config and lua/plugins.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
