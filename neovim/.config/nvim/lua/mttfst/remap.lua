local vim = vim
-- local set = vim.opt


vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Move lines up and down (ThePrimeagen)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- navigate windows
vim.keymap.set('', '<leader>h', ':wincmd h<CR>')
vim.keymap.set('', '<leader>j', ':wincmd j<CR>')
vim.keymap.set('', '<leader>k', ':wincmd k<CR>')
vim.keymap.set('', '<leader>l', ':wincmd l<CR>')


vim.keymap.set('n', '<leader>wm', vim.cmd.make)
