-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- print('Hallo from Packer')

local vim = vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use({ 'rose-pine/neovim', as = 'rose-pine' })

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')

    use('tpope/vim-fugitive')
    use('tpope/vim-commentary')

    use('mbbill/undotree')

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-path' },     -- Required
            { 'hrsh7th/cmp-buffer' },   -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        }
    }

    use({
        "nvimtools/none-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    })

    use { 'akinsho/git-conflict.nvim', tag = "*", config = function()
        require('git-conflict').setup()
    end }

    use('lervag/vimtex')
end)
