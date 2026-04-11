# hirovim

Personal Neovim configuration built from scratch on top of [lazy.nvim](https://github.com/folke/lazy.nvim).

## Structure

```
init.lua              # entry point
lua/
├── config/
│   ├── options.lua   # vim.opt
│   ├── keymaps.lua   # keymaps
│   ├── autocmds.lua  # autocommands
│   └── lazy.lua      # lazy.nvim bootstrap + spec loader
└── plugins/
    ├── lsp.lua
    ├── completion.lua
    ├── treesitter.lua
    ├── telescope.lua
    ├── ui.lua
    └── editor.lua
```

## Install

```sh
git clone https://github.com/<user>/hirovim.git ~/Develops/iwashitahga/hirovim
# back up anything existing, then:
ln -s ~/Develops/iwashitahga/hirovim ~/.config/nvim
nvim
```

On first launch lazy.nvim bootstraps itself and installs plugins.
