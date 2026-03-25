-- Define the path where lazy.nvim will be installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- If it's not installed, clone it from GitHub
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

-- Add lazy.nvim to Neovim's runtime path
vim.opt.rtp:prepend(lazypath)

-- Initialize lazy with an empty plugin list
require("lazy").setup({
    -- 1. The Colorscheme
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            vim.cmd("colorscheme rose-pine")
        end
    },

    -- 2. Telescope (Fuzzy Finder)
    {
        'nvim-telescope/telescope.nvim', 
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            -- Primeagen's exact Telescope remaps
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
        end
    },

    -- 3. Treesitter (Using the pcall failsafe)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- Wrap it in a pcall (protected call) so it doesn't crash your whole editor if it fails
            local status_ok, configs = pcall(require, "nvim-treesitter.configs")
            if not status_ok then
                print("Treesitter failed to load, but editor is safe!")
                return
            end

            configs.setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
                sync_install = false,
                auto_install = true,
               highlight = { enable = true },
            })
        end
    },

    -- 4. Harpoon (Project Navigation)
    {
        "theprimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            -- Space + a to add a file to Harpoon
            vim.keymap.set("n", "<leader>a", mark.add_file)
            -- Ctrl + e to view the Harpoon menu
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

            -- Instantly navigate to files 1-4 in your Harpoon list
            vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)
        end
    },

    -- 5. UndoTree (Visual Undo History)
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },

    -- 6. LazyGit (Visual Git TUI)
    {
        "kdheepak/lazygit.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            -- Press Leader + lg to open LazyGit
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
        },
    }, 

    -- 7. LSP Support & Autocompletion (The IDE Experience)
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},
            {'neovim/nvim-lspconfig'},
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'hrsh7th/cmp-nvim-lua'},
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({buffer = bufnr})
            end)

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = {'lua_ls'}, 
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                },
            })

            local cmp = require('cmp')
            local cmp_select = {behavior = cmp.SelectBehavior.Select}

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                })
            })
        end
    }
})
