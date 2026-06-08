-- Absolute line number on the current line, relative on all others.
-- Relative numbers let you jump with e.g. `12j` without counting manually.
vim.opt.nu = true
vim.opt.relativenumber = true

-- Sync the unnamed register with the OS clipboard.
-- Without this, yanks stay inside Neovim and never reach other applications.
vim.opt.clipboard = "unnamedplus"

-- 4-space soft tabs. softtabstop makes <BS> delete a full indent level,
-- not just a single space.
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- Horizontal scrolling instead of wrapping. Avoids layout confusion in code.
vim.opt.wrap = false

-- Persistent undo survives file saves and full editor restarts.
-- swapfile and backup are redundant once undofile is on.
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- incsearch highlights matches while typing; hlsearch off avoids the leftover
-- highlight after a search is done (no need to :noh every time).
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Required for true-color themes. Without this, TokyoNight renders as 256-color.
vim.opt.termguicolors = true

-- Keep context visible: 8 lines always shown above and below the cursor.
vim.opt.scrolloff = 8

-- Always reserve the sign column so LSP diagnostics don't shift the text sideways.
vim.opt.signcolumn = "yes"

-- Allow @ in filenames so `gf` (go-to-file) resolves module paths like `@utils/foo`.
vim.opt.isfname:append("@-@")

-- CursorHold fires after this many ms of inactivity.
-- LSP uses this event to trigger hover docs and diagnostics refresh.
vim.opt.updatetime = 50
