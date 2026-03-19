# Neovim "Giga Chad" Setup

## Overview
This is a modern, highly optimized Neovim configuration built entirely in Lua. It transforms standard Neovim into a blazing-fast, fully-fledged IDE with intelligent code completion, lightning-fast file navigation, and deep Git integration. 

## The Core Engine
* **Language:** Lua
* **Plugin Manager:** `lazy.nvim`. It automatically bootstraps itself on the first run and lazy-loads plugins (like Treesitter) only when needed, keeping startup times near zero.
* **Architecture:** Modular. The `init.lua` root file requires specific configuration files located in the `lua/kaisar/` directory (`set.lua`, `remap.lua`, and `lazy.lua`).

## The Plugin Stack
* **Rose Pine (`rose-pine/neovim`):** The primary color scheme, providing a clean, dark, high-contrast aesthetic.
* **Telescope (`nvim-telescope/telescope.nvim`):** A highly extensible fuzzy finder. It instantly searches through your entire project for files, words, or Git commits.
* **Treesitter (`nvim-treesitter/nvim-treesitter`):** Replaces Neovim's standard regex-based syntax highlighting with an Abstract Syntax Tree (AST). This provides incredibly accurate, deep colorization for your code.
* **Harpoon (`theprimeagen/harpoon`):** A project navigation tool. Instead of opening a file tree to switch between the 3 or 4 files you are actively working on, Harpoon lets you bookmark them and jump between them instantly with a single keystroke.
* **Undotree (`mbbill/undotree`):** A visual undo history. It tracks every edit you make in a branching tree, allowing you to easily revert to older versions of a file even after saving.
* **Fugitive (`tpope/vim-fugitive`):** The premier Git wrapper for Vim. It allows you to run Git commands (like status, commit, and push) directly inside Neovim.
* **LSP-Zero (`VonHeikemen/lsp-zero.nvim`):** The "IDE Brain." It bundles several tools together to provide code intelligence:
  * **Mason:** A built-in app store to download language servers (like Python, Lua, or C++).
  * **Cmp:** The autocompletion engine that displays the dropdown menu for code suggestions.
  * **LuaSnip:** The engine that handles code snippets.

---

## Master Keybindings Cheat Sheet

Here are the custom remaps configured for maximum speed:

| Keystroke | Mode | Action | Plugin |
| :--- | :--- | :--- | :--- |
| **`Space`** | Normal | **Leader Key** (Starts custom commands) | *Core* |
| `<leader>pv` | Normal | Open Netrw (Built-in File Explorer) | *Core* |
| `<leader>pf` | Normal | Find all files in project | Telescope |
| `<C-p>` | Normal | Find only Git-tracked files | Telescope |
| `<leader>ps` | Normal | Grep (search for a specific word/string) | Telescope |
| `<leader>a` | Normal | Add current file to Harpoon list | Harpoon |
| `<C-e>` | Normal | Open Harpoon quick menu | Harpoon |
| `<C-h>` | Normal | Jump to Harpoon file #1 | Harpoon |
| `<C-t>` | Normal | Jump to Harpoon file #2 | Harpoon |
| `<C-n>` | Normal | Jump to Harpoon file #3 | Harpoon |
| `<C-s>` | Normal | Jump to Harpoon file #4 | Harpoon |
| `<leader>u` | Normal | Toggle visual Undo history tree | Undotree |
| `<leader>gs` | Normal | Open Git Status | Fugitive |
| `<C-Space>` | Insert | Trigger autocompletion menu | LSP (Cmp) |
| `<C-n>` | Insert | Move to **next** item in autocomplete menu | LSP (Cmp) |
| `<C-p>` | Insert | Move to **previous** item in autocomplete menu | LSP (Cmp) |
| `<C-y>` | Insert | **Confirm/Yes** to autocomplete suggestion | LSP (Cmp) |
