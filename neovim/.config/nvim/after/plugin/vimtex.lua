vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_compiler_progname = 'nvr'

vim.keymap.set('n', '<leader>to', vim.cmd.VimtexTocToggle)
vim.keymap.set('n', '<leader>tv', vim.cmd.VimtexView)
vim.keymap.set('n', '<leader>tc', vim.cmd.VimtexCompile)

-- vim.let.vimtex_grammar_textidote = { 'jar': '~/.vim/textiode/textidote.jar', 'args': '--output singleline --check en_UK',}
