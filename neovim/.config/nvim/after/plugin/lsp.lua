local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
end)

lsp.ensure_installed({
    -- Replace these with whatever servers you want to install
    'fortls',
    'ltex',
    'pylsp',
    'lua_ls',
    'bashls'
})

lsp.format_on_save({
    servers = {
        ['pylsp'] = { 'python' },
        ['lua_ls'] = { 'lua' },
    }
})


lsp.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

manage_nvim_cmp = {
    set_sources = 'lsp',
    set_basic_mappings = true,
    set_extra_mappings = false,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
}

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'buffer' },
    },
    mapping = {
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
    }
})
