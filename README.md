# Neovim Setup

## Overview
A modern Neovim configuration built entirely in Lua. Transforms standard Neovim into a blazing-fast IDE with intelligent code completion, lightning-fast file navigation, and deep Git integration.

## Core Engine
- **Language:** Lua
- **Plugin Manager:** `lazy.nvim` — auto-bootstraps on first run, lazy-loads plugins to keep startup near zero.
- **Architecture:** Modular. `init.lua` requires `lua/remboaq/set.lua`, `remap.lua`, and `lazy.lua`.

## Theme
- **TokyoNight** (`moon` style) — dark blue background, transparent editor (inherits terminal background).
- Cyberpunk neon red (`#ff003c`) applied to all keywords (`if`, `for`, `return`, `function`, etc.).
- Vivid cyan (`#00e5e5`) on info diagnostics.
- Floats (hover, completion, terminal) use TokyoNight's dark blue solid background (`bg_dark`).

## Plugin Stack

| Plugin | Purpose |
| :----- | :------ |
| `folke/tokyonight.nvim` | Color theme |
| `nvim-telescope/telescope.nvim` | Fuzzy finder for files and text |
| `nvim-treesitter/nvim-treesitter` | AST-based syntax highlighting |
| `theprimeagen/harpoon` | Bookmark up to 4 files and jump instantly |
| `mbbill/undotree` | Visual branching undo history |
| `kdheepak/lazygit.nvim` | Full Git TUI inside Neovim |
| `VonHeikemen/lsp-zero.nvim` | LSP + Mason + nvim-cmp + LuaSnip |
| `stevearc/oil.nvim` | File explorer as an editable buffer |

---

## Keybindings Cheat Sheet

> **Leader key = `Space`**

---

### Navigation

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<C-d>` | Normal | Half-page **down**, cursor stays centered |
| `<C-u>` | Normal | Half-page **up**, cursor stays centered |

---

### File Explorer (Oil)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<leader>pv` | Normal | Open Oil file explorer |

---

### Fuzzy Finder (Telescope)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<leader>pf` | Normal | Find **all** files in project |
| `<C-p>` | Normal | Find **Git-tracked** files only |
| `<leader>ps` | Normal | Grep — search for a string across project |

---

### File Bookmarks (Harpoon)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<leader>a` | Normal | Add current file to Harpoon list |
| `<C-e>` | Normal | Toggle Harpoon quick menu |
| `<C-h>` | Normal | Jump to bookmarked file **#1** |
| `<C-t>` | Normal | Jump to bookmarked file **#2** |
| `<C-n>` | Normal | Jump to bookmarked file **#3** |
| `<C-s>` | Normal | Jump to bookmarked file **#4** |

---

### Undo History (Undotree)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<leader>u` | Normal | Toggle visual undo history tree |

---

### Git (LazyGit)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<leader>lg` | Normal | Open LazyGit TUI |

---

### LSP — Code Intelligence

| Key | Mode | Action |
| :-- | :--- | :----- |
| `gd` | Normal | Go to **definition** |
| `gr` | Normal | Go to **references** |
| `K` | Normal | Show **hover** documentation |
| `<leader>rn` | Normal | **Rename** symbol |
| `<leader>ca` | Normal | **Code action** (quick fixes, imports…) |
| `[d` | Normal | Jump to **previous** diagnostic |
| `]d` | Normal | Jump to **next** diagnostic |
| `<leader>e` | Normal | Open **diagnostic float** (error details) |

Diagnostics show inline to the right of code with severity icons:
- `` Error (red, undercurl)
- `` Warning (yellow, undercurl)
- `` Info (cyan)
- `` Hint (teal)

Unused/unnecessary code is grayed out and italic automatically.

---

### Autocompletion (nvim-cmp)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<C-Space>` | Insert | Trigger completion menu |
| `<Tab>` | Insert | Select **next** item |
| `<S-Tab>` | Insert | Select **previous** item |
| `<C-n>` | Insert | Select **next** item |
| `<C-p>` | Insert | Select **previous** item |
| `<C-y>` | Insert | **Confirm** selected completion |
| `<C-e>` | Insert | **Abort** / close completion menu |

---

### Editing

| Key | Mode | Action |
| :-- | :--- | :----- |
| `J` | Visual | Move selected lines **down** |
| `K` | Visual | Move selected lines **up** |
| `<leader>y` | Normal / Visual | Yank to **system clipboard** |
| `<leader>Y` | Normal | Yank line to **system clipboard** |
| `<leader>d` | Normal / Visual | Delete to **void register** (preserves clipboard) |

---

### Running Files (`<leader>rp`)

| Key | Mode | Action |
| :-- | :--- | :----- |
| `<leader>rp` | Normal | Run current file in a **centered floating terminal** |
| `<Esc>` | Terminal | Exit terminal input mode |
| `q` | Normal | Close the floating terminal |

Supports the following filetypes:

| Filetype | Command |
| :------- | :------ |
| `python` | `python3 file.py` |
| `cpp` | `g++ -std=c++17 file.cpp -o /tmp/file && /tmp/file` |
| `c` | `gcc file.c -o /tmp/file && /tmp/file` |
| `javascript` | `node file.js` |
| `typescript` | `ts-node file.ts` |
| `sh` | `bash file.sh` |
| `lua` | `lua file.lua` |

**ROS2 support:** if a `install/setup.bash` is found by walking up from the directory where Neovim was opened, it is sourced automatically before running Python. This makes all built ROS2 packages importable without a virtual environment.

Always run Python from the directory where you opened Neovim:
```bash
cd ~/your_ros2_ws
colcon build
nvim .
```

---

## ROS2 LSP Setup

Pyright (the Python LSP) does not inherit the ROS2 environment automatically. Run this command once per workspace to generate a `pyrightconfig.json` that points pyright to all ROS2 Python paths:

```
:RosPyrightSetup
```

This command:
1. Walks up from `cwd` to find `install/setup.bash`
2. Sources it and captures the full `sys.path` from Python
3. Writes `pyrightconfig.json` at the workspace root
4. Restarts the LSP automatically

Re-run after adding new packages with `colcon build`.

---

## LSP Servers (auto-installed via Mason)

| Server | Language |
| :----- | :------- |
| `lua_ls` | Lua |
| `pyright` | Python |

Add more servers to `ensure_installed` in `lazy.lua` (Mason will install them on next startup).
