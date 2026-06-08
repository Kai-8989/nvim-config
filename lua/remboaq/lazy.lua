-- ─── Bootstrap lazy.nvim ─────────────────────────────────────────────────────
-- lazy.nvim is the plugin manager. On a fresh machine this block clones it from
-- GitHub before anything else runs, making the config fully self-installing.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

-- Prepend so lazy.nvim is found before any other runtimepath entry.
vim.opt.rtp:prepend(lazypath)

-- ─── Plugins ─────────────────────────────────────────────────────────────────
require("lazy").setup({

    -- ── 1. TokyoNight (Color Theme) ──────────────────────────────────────────
    -- lazy=false + priority=1000 forces this to load first, synchronously.
    -- All other plugins load after and inherit the correct highlight groups.
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('tokyonight').setup({
                style = 'moon',
                -- Transparent background lets the terminal's own color show through,
                -- making Neovim blend seamlessly with the terminal theme.
                transparent = true,
                italic_comments = true,

                -- on_colors runs before highlights are applied; mutating the palette
                -- here propagates the change to every group that references these slots.
                on_colors = function(c)
                    c.red  = '#ff003c' -- cyberpunk neon red
                    c.cyan = '#00e5e5' -- vivid cyan
                end,

                -- on_highlights runs after the palette is resolved. Use it for groups
                -- that need explicit overrides rather than palette-level changes.
                on_highlights = function(hl, c)
                    -- Floats get a solid bg_dark background so they remain legible
                    -- even though the main editor is transparent.
                    hl.NormalFloat = { bg = c.bg_dark, fg = c.fg }
                    hl.FloatBorder = { bg = c.bg_dark, fg = c.blue0 }

                    -- Sign column icons (left gutter)
                    hl.DiagnosticSignError = { fg = c.red,    bold = true }
                    hl.DiagnosticSignWarn  = { fg = c.yellow, bold = true }
                    hl.DiagnosticSignInfo  = { fg = c.cyan,   bold = true }
                    hl.DiagnosticSignHint  = { fg = c.teal,   bold = true }

                    -- Inline virtual text shown to the right of the offending line
                    hl.DiagnosticVirtualTextError = { fg = c.red,    italic = true }
                    hl.DiagnosticVirtualTextWarn  = { fg = c.yellow, italic = true }

                    -- Undercurl (wavy underline) uses `sp` as the curl color.
                    hl.DiagnosticUnderlineError = { sp = c.red,    undercurl = true }
                    hl.DiagnosticUnderlineWarn  = { sp = c.yellow, undercurl = true }

                    -- Dim unused/unnecessary code the same way comments are dimmed.
                    hl.DiagnosticUnnecessary = { fg = c.comment, italic = true }
                end,
            })

            vim.cmd.colorscheme('tokyonight')

            -- Treesitter @keyword groups are set AFTER the colorscheme loads because
            -- on_highlights is unreliable for @ groups in some TokyoNight versions.
            -- Setting them here via nvim_set_hl guarantees the override takes effect.
            -- Both treesitter groups and legacy Vim groups are set so every filetype
            -- gets the cyberpunk red regardless of whether treesitter is active.
            local red = '#ff003c'
            local keyword_groups = {
                '@keyword', '@keyword.return', '@keyword.conditional',
                '@keyword.repeat', '@keyword.function', '@keyword.import',
                'Keyword', 'Conditional', 'Repeat', 'Include',
            }
            for _, group in ipairs(keyword_groups) do
                vim.api.nvim_set_hl(0, group, { fg = red, bold = true })
            end
        end,
    },

    -- ── 2. Telescope (Fuzzy Finder) ──────────────────────────────────────────
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            -- git_files is faster than find_files in large repos because it only
            -- searches tracked files, skipping build artifacts and node_modules.
            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
        end,
    },

    -- ── 3. Treesitter (Syntax Highlighting) ──────────────────────────────────
    {
        "nvim-treesitter/nvim-treesitter",
        -- :TSUpdate keeps grammar parsers in sync with the plugin version.
        build = ":TSUpdate",
        config = function()
            -- pcall prevents a broken parser from crashing the entire editor.
            local status_ok, configs = pcall(require, "nvim-treesitter.configs")
            if not status_ok then
                vim.notify("Treesitter failed to load", vim.log.levels.WARN)
                return
            end

            configs.setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python" },
                -- async install avoids blocking the editor on first launch.
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
            })
        end,
    },

    -- ── 4. Harpoon (File Bookmarks) ───────────────────────────────────────────
    -- Harpoon keeps a per-project list of up to 4 files. Jumping between them
    -- is instant (no fuzzy search), which makes it faster than Telescope for
    -- files you switch between constantly.
    {
        "theprimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local mark = require("harpoon.mark")
            local ui   = require("harpoon.ui")

            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>",     ui.toggle_quick_menu)

            vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)
        end,
    },

    -- ── 5. Undotree (Visual Undo History) ────────────────────────────────────
    -- Neovim's undo history is a tree, not a stack. Undotree visualizes the
    -- full branch structure so you can recover any previous state even after
    -- branching edits.
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end,
    },

    -- ── 6. LazyGit (Git TUI) ─────────────────────────────────────────────────
    {
        "kdheepak/lazygit.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        -- `keys` makes lazy.nvim load this plugin only when the keymap fires,
        -- keeping startup time near zero.
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
        },
    },

    -- ── 7. LSP + Completion ───────────────────────────────────────────────────
    -- lsp-zero wires together three independent systems:
    --   Mason       — downloads and manages LSP server binaries
    --   nvim-lspconfig — configures each server for Neovim's LSP client
    --   nvim-cmp    — completion engine that reads from the active LSP server
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'neovim/nvim-lspconfig' },
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            -- on_attach runs once per buffer when an LSP server connects.
            -- Keymaps are buffer-local so they only activate in LSP-aware files.
            lsp_zero.on_attach(function(client, bufnr)
                local opts = { buffer = bufnr }
                vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,  opts)
                vim.keymap.set('n', 'K',           vim.lsp.buf.hover,       opts)
                vim.keymap.set('n', 'gr',          vim.lsp.buf.references,  opts)
                vim.keymap.set('n', '<leader>rn',  vim.lsp.buf.rename,      opts)
                vim.keymap.set('n', '<leader>ca',  vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

                -- Open the diagnostic float and apply the DiagBorder highlight so the
                -- border color matches the rest of the UI rather than using the default.
                vim.keymap.set('n', '<leader>e', function()
                    local _, win = vim.diagnostic.open_float({ border = 'rounded' })
                    if win then
                        vim.api.nvim_set_option_value('winhighlight', 'FloatBorder:DiagBorder', { win = win })
                    end
                end, opts)
            end)

            require('mason').setup({})
            require('mason-lspconfig').setup({
                -- Servers listed here are auto-installed on first launch if missing.
                ensure_installed = { 'lua_ls', 'pyright' },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                },
            })

            local cmp        = require('cmp')
            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                window = {
                    completion    = { border = 'rounded', scrollbar = false },
                    documentation = { border = 'rounded' },
                },
                mapping = cmp.mapping.preset.insert({
                    ['<Tab>']     = cmp.mapping.select_next_item(cmp_select),
                    ['<S-Tab>']   = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>']     = cmp.mapping.select_next_item(cmp_select),
                    ['<C-p>']     = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-y>']     = cmp.mapping.confirm({ select = true }),
                    ['<C-e>']     = cmp.mapping.abort(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                }),
                -- Primary sources (LSP, snippets, Neovim API) take precedence;
                -- buffer and path are fallbacks when the primary sources return nothing.
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'nvim_lua' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })

            -- Link DiagBorder to FloatBorder so the diagnostic float border
            -- automatically inherits any future theme changes to FloatBorder.
            vim.api.nvim_set_hl(0, 'DiagBorder', { link = 'FloatBorder' })

            vim.diagnostic.config({
                -- Errors always appear before warnings when multiple diagnostics
                -- share the same line, so the most critical issue is seen first.
                severity_sort = true,

                -- Show a severity icon as the virtual text prefix so each message
                -- is visually distinct without repeating a generic symbol.
                virtual_text = {
                    spacing = 4,
                    prefix = function(d)
                        local icons = {
                            [vim.diagnostic.severity.ERROR] = '',
                            [vim.diagnostic.severity.WARN]  = '',
                            [vim.diagnostic.severity.INFO]  = '',
                            [vim.diagnostic.severity.HINT]  = '',
                        }
                        return icons[d.severity] or '●'
                    end,
                },

                -- Sign column icons (mirrors the virtual text icons for consistency).
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '',
                        [vim.diagnostic.severity.WARN]  = '',
                        [vim.diagnostic.severity.INFO]  = '',
                        [vim.diagnostic.severity.HINT]  = '',
                    },
                },

                underline = true,
                float = { border = 'rounded' },
            })
        end,
    },

    -- ── 8. Oil (File Explorer) ────────────────────────────────────────────────
    -- Oil renders the filesystem as a regular buffer: rename files with `cw`,
    -- delete with `dd`, move by cutting and pasting lines. Far faster than
    -- tree-based explorers for bulk operations.
    {
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                -- Replaces Netrw so `nvim .` opens Oil instead of the default explorer.
                default_file_explorer = true,
                view_options = {
                    show_hidden = true,
                },
            })
            vim.keymap.set("n", "<leader>pv", "<cmd>Oil<CR>", { desc = "Open Oil file explorer" })
        end,
    },
})
