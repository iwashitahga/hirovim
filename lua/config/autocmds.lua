local augroup = function(name)
  return vim.api.nvim_create_augroup("hirovim_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, [["]])
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_trailing_ws"),
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Resize splits when vim is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  command = "tabdo wincmd =",
})

-- Reload buffers changed on disk.
--
-- An agent (claude) edits files in the same worktree while they are open here,
-- so without this the buffer goes stale and :w reports W12 and clobbers the
-- agent's edits. 'autoread' only takes effect when something triggers a check,
-- hence the :checktime calls below.
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
  group = augroup("check_file_changed"),
  callback = function()
    -- Skip command-line window and unnamed/special buffers.
    if vim.fn.getcmdwintype() ~= "" or vim.bo.buftype ~= "" then
      return
    end
    vim.cmd("checktime")
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = augroup("file_changed_notify"),
  callback = function()
    vim.notify("Buffer reloaded from disk", vim.log.levels.INFO)
  end,
})
