# hirovim

Personal Neovim configuration, built from scratch on top of [lazy.nvim](https://github.com/folke/lazy.nvim).

Requires Neovim **0.11+** (uses the new `vim.lsp.config` / `vim.lsp.enable` API and the `nvim-treesitter` `main` branch rewrite, which needs 0.12+ for full feature parity).

## Install

Neovim reads its config from `$XDG_CONFIG_HOME/nvim` (defaults to `~/.config/nvim`). Clone this repo wherever you keep your dev checkouts and symlink it into place — that way the working tree lives next to the rest of your code.

```sh
# Pick any path you like for the actual checkout
REPO_DIR="$HOME/path/to/hirovim"

# 1. Clone
git clone git@github.com:iwashitahga/hirovim.git "$REPO_DIR"

# 2. Back up any existing nvim config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true

# 3. Symlink into XDG config
ln -s "$REPO_DIR" ~/.config/nvim

# 4. Launch — lazy.nvim bootstraps itself and installs plugins on first run
nvim
```

If you'd rather clone directly into `~/.config/nvim`, that works too — the symlink step is just for keeping the repo near the rest of your dev tree.

### External dependencies

Installed automatically by Mason / lazy.nvim where possible, but a few binaries have to exist on `$PATH`:

- `git`, a C compiler, `make` — for building plugins and treesitter parsers
- [`tree-sitter`](https://github.com/tree-sitter/tree-sitter) CLI — required by the `nvim-treesitter` `main` branch
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) — Telescope live_grep
- [`fd`](https://github.com/sharkdp/fd) — Telescope find_files (optional but recommended)

## Structure

```
init.lua               # entry point (leader key + config loaders)
lua/
├── config/
│   ├── options.lua    # vim.opt
│   ├── keymaps.lua    # global keymaps
│   ├── autocmds.lua   # autocommands
│   └── lazy.lua       # lazy.nvim bootstrap + spec loader
└── plugins/
    ├── lsp.lua        # mason + nvim-lspconfig (vim.lsp.config API)
    ├── completion.lua # nvim-cmp + LuaSnip
    ├── treesitter.lua # nvim-treesitter (main branch)
    ├── telescope.lua  # fuzzy finder
    ├── bufferline.lua # tab-style buffer line
    ├── filer.lua      # neo-tree sidebar
    ├── oil.lua        # edit-as-buffer directory view
    ├── git.lua        # gitsigns + diffview
    ├── flash.lua      # 2-char jump motion
    ├── formatting.lua # conform.nvim
    ├── linting.lua    # nvim-lint
    ├── editor.lua     # misc editor QoL
    └── ui.lua         # colorscheme, statusline, dashboard, etc.
```

## Keymaps (cheat sheet)

Leader = `<Space>`.

**Tabs (buffers)** — `Opt+h` / `Opt+l` prev/next, `Opt+H` / `Opt+L` move, `<leader>bd` close
**Windows** — `Ctrl+h/j/k/l` move, `Ctrl+↑↓←→` resize
**Files** — `<leader>ff` find, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fr` recent
**Filer** — `<leader>e` Neo-tree toggle, `-` oil (parent dir)
**LSP** — `gd` def, `gr` refs, `K` hover, `<leader>rn` rename, `<leader>ca` code action, `[d`/`]d` diagnostics
**Git** — `]h`/`[h` hunk nav, `<leader>gp/gs/gr` preview/stage/reset hunk, `<leader>gv` Diffview
**Jump** — `s` flash, `S` flash-treesitter
**Format / lint** — `<leader>lf` format, `<leader>ll` lint

Full list: `:Telescope keymaps`.
