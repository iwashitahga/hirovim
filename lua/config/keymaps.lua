local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear hlsearch")

-- Save / quit
map("n", "<leader>w", "<cmd>write<CR>", "Save file")
map("n", "<leader>q", "<cmd>confirm quit<CR>", "Quit")

-- Window navigation
map("n", "<C-h>", "<C-w>h", "Go to left window")
map("n", "<C-j>", "<C-w>j", "Go to lower window")
map("n", "<C-k>", "<C-w>k", "Go to upper window")
map("n", "<C-l>", "<C-w>l", "Go to right window")

-- Window resize
map("n", "<C-Up>", "<cmd>resize +2<CR>", "Increase window height")
map("n", "<C-Down>", "<cmd>resize -2<CR>", "Decrease window height")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Decrease window width")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Increase window width")

-- Buffer / tab navigation.
map("n", "<A-l>", "<cmd>BufferLineCycleNext<CR>", "Next tab")
map("n", "<A-h>", "<cmd>BufferLineCyclePrev<CR>", "Previous tab")
map("n", "<A-L>", "<cmd>BufferLineMoveNext<CR>", "Move tab right")
map("n", "<A-H>", "<cmd>BufferLineMovePrev<CR>", "Move tab left")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")

-- Better indent in visual mode
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

-- Keep cursor centered on half-page jumps and search
map("n", "<C-d>", "<C-d>zz", "Half page down (centered)")
map("n", "<C-u>", "<C-u>zz", "Half page up (centered)")
map("n", "n", "nzzzv", "Next match (centered)")
map("n", "N", "Nzzzv", "Previous match (centered)")
