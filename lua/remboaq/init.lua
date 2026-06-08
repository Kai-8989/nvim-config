-- mapleader must be set before any plugin or keymap loads.
-- Plugins read it at setup time, so a late assignment would leave them with the default '\'.
vim.g.mapleader = " "

require("remboaq.set")    -- editor options
require("remboaq.remap")  -- keybindings and commands
require("remboaq.lazy")   -- plugin manager and plugin configs
