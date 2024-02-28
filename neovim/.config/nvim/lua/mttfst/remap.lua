local vim = vim
local set = vim.opt


vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Move lines up and down (ThePrimeagen)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


vim.keymap.set('n', '<leader>wm', vim.cmd.make)

set.makeprg = './make.sh pcosmus_GF10'
-- set.makeprg = './make.sh dustonly_GF'
-- set.t_Co = 256
