local map = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end

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
-- Delete the current buffer while keeping the window layout intact.
-- Plain `:bdelete` can close the last editor window, which combined with
-- neo-tree's close_if_last_window lets the whole Neovim instance exit.
local function close_buffer()
  local current = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(b) return vim.bo[b].buflisted and b ~= current end, vim.api.nvim_list_bufs())
  if #listed == 0 then
    vim.cmd "enew" -- spawn a fresh [No Name] so the window survives
  else
    vim.cmd "bprevious"
  end
  if vim.api.nvim_buf_is_valid(current) then vim.cmd("bdelete! " .. current) end
end
map("n", "<leader>bd", close_buffer, "Delete buffer")
map("n", "<A-w>", close_buffer, "Delete buffer")

-- Close quickfix / location list (the panel that appears after gd, gr, etc.)
map("n", "gq", function()
  vim.cmd "cclose"
  vim.cmd "lclose"
end, "Close quickfix / loclist")

-- GitHub PR helpers via the `gh` CLI (no octo load required).
-- Output shows in cmdline so the PR URL / status message stays visible.
map("n", "<leader>gc", "<cmd>!gh pr create --draft --fill<CR>", "PR: create draft")
map("n", "<leader>gC", "<cmd>!gh pr create --fill<CR>", "PR: create ready")
map("n", "<leader>gm", "<cmd>!gh pr ready<CR>", "PR: mark ready")
map("n", "<leader>gM", "<cmd>!gh pr ready --undo<CR>", "PR: mark draft")

-- Send review comments to the agent (claude) running in the neighbouring
-- herdr pane. `herdr-tell` resolves the target itself: the agent pane sharing
-- this pane's tab. Nothing happens outside herdr, so it is safe to have bound.
--
-- Two flavours:
--   <leader>ac  comment on this line/selection and send it right away
--   <leader>aa  queue a comment on this line/selection (Confluence-style:
--               mark up several spots first, review, then submit as one)
--   <leader>as  send all queued comments as a single message, then clear
--   <leader>al  list queued comments in the quickfix window
--   <leader>ax  clear queued comments without sending

-- Captures the current line or visual selection: location string, code
-- snippet and enough to re-find it later for a highlight/extmark.
local function capture_range(mode)
  local buf_path = vim.fn.expand("%:.")
  if buf_path == "" then
    vim.notify("No file in this buffer", vim.log.levels.WARN)
    return nil
  end

  local line1, line2
  if mode == "visual" then
    line1, line2 = vim.fn.line("v"), vim.fn.line(".")
    if line1 > line2 then
      line1, line2 = line2, line1
    end
    -- Leave visual mode. The "x" flag matters: with a plain feedkeys the <Esc>
    -- stays in the typeahead and then cancels the vim.ui.input() prompt opened
    -- below, so the mapping silently does nothing.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  else
    line1 = vim.fn.line(".")
    line2 = line1
  end

  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  local loc = line1 == line2 and (buf_path .. ":" .. line1)
    or (buf_path .. ":" .. line1 .. "-" .. line2)

  return {
    bufnr = vim.api.nvim_get_current_buf(),
    loc = loc,
    line1 = line1,
    line2 = line2,
    code = table.concat(lines, "\n"),
    filetype = vim.bo.filetype or "",
  }
end

local function comment_to_agent(mode)
  local r = capture_range(mode)
  if not r then
    return
  end
  -- Defer so any pending key handling (which-key restoring the mode, the <Esc>
  -- above) settles before the prompt takes over the cmdline.
  vim.schedule(function()
    vim.ui.input({ prompt = "comment on " .. r.loc .. ": " }, function(comment)
      if not comment or comment == "" then
        return
      end
      local body = table.concat({ r.loc, "```" .. r.filetype, r.code, "```", comment }, "\n")
      vim.system({ "herdr-tell", "--quiet" }, { stdin = body }, function(res)
        vim.schedule(function()
          if res.code == 0 then
            vim.notify("sent to agent: " .. r.loc, vim.log.levels.INFO)
          else
            vim.notify("herdr-tell failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
          end
        end)
      end)
    end)
  end)
end

map("n", "<leader>ac", function() comment_to_agent("normal") end, "Agent: comment on this line")
map("x", "<leader>ac", function() comment_to_agent("visual") end, "Agent: comment on selection")

-- Queued (Confluence-style, review-then-submit) comments -------------------

local pending_ns = vim.api.nvim_create_namespace("agent_pending_comments")
vim.api.nvim_set_hl(0, "AgentPendingComment", { link = "Visual", default = true })

---@type { bufnr: integer, loc: string, code: string, filetype: string, comment: string, extmark_id: integer }[]
local pending = {}

local function queue_comment(mode)
  local r = capture_range(mode)
  if not r then
    return
  end
  vim.schedule(function()
    vim.ui.input({ prompt = "queue comment on " .. r.loc .. ": " }, function(comment)
      if not comment or comment == "" then
        return
      end
      local last_line = vim.api.nvim_buf_get_lines(r.bufnr, r.line2 - 1, r.line2, false)[1] or ""
      local extmark_id = vim.api.nvim_buf_set_extmark(r.bufnr, pending_ns, r.line1 - 1, 0, {
        end_row = r.line2 - 1,
        end_col = #last_line,
        hl_group = "AgentPendingComment",
        sign_text = "💬",
        sign_hl_group = "DiagnosticSignInfo",
        virt_text = { { " " .. comment, "Comment" } },
        virt_text_pos = "eol",
      })
      table.insert(pending, {
        bufnr = r.bufnr,
        loc = r.loc,
        code = r.code,
        filetype = r.filetype,
        comment = comment,
        extmark_id = extmark_id,
      })
      vim.notify(("queued (%d): %s"):format(#pending, r.loc), vim.log.levels.INFO)
    end)
  end)
end

local function clear_pending()
  for _, p in ipairs(pending) do
    if vim.api.nvim_buf_is_valid(p.bufnr) then
      pcall(vim.api.nvim_buf_del_extmark, p.bufnr, pending_ns, p.extmark_id)
    end
  end
  local count = #pending
  pending = {}
  if count > 0 then
    vim.notify(("cleared %d queued comment(s)"):format(count), vim.log.levels.INFO)
  end
end

local function list_pending()
  if #pending == 0 then
    vim.notify("no queued comments", vim.log.levels.INFO)
    return
  end
  local qf = {}
  for _, p in ipairs(pending) do
    table.insert(qf, { bufnr = p.bufnr, lnum = p.loc:match(":(%d+)") or 1, text = p.comment })
  end
  vim.fn.setqflist(qf, "r")
  vim.cmd "copen"
end

local function send_pending()
  if #pending == 0 then
    vim.notify("no queued comments to send", vim.log.levels.WARN)
    return
  end
  local parts = {}
  for i, p in ipairs(pending) do
    table.insert(
      parts,
      table.concat({ ("### %d. %s"):format(i, p.loc), "```" .. p.filetype, p.code, "```", p.comment }, "\n")
    )
  end
  local body = table.concat(parts, "\n\n")
  local count = #pending
  vim.system({ "herdr-tell", "--quiet" }, { stdin = body }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify(("sent %d queued comment(s) to agent"):format(count), vim.log.levels.INFO)
        clear_pending()
      else
        vim.notify("herdr-tell failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

map("n", "<leader>aa", function() queue_comment("normal") end, "Agent: queue comment on this line")
map("x", "<leader>aa", function() queue_comment("visual") end, "Agent: queue comment on selection")
map("n", "<leader>as", send_pending, "Agent: send queued comments")
map("n", "<leader>al", list_pending, "Agent: list queued comments")
map("n", "<leader>ax", clear_pending, "Agent: clear queued comments")

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
