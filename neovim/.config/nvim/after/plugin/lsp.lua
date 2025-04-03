local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    -- disable tsserver formatting if using prettier
    if client.name == "tsserver" then
        client.server_capabilities.documentFormattingProvider = false
    end

    lsp.default_keymaps({ buffer = bufnr })
end)

lsp.ensure_installed({
    -- Replace these with whatever servers you want to install
    'fortls',
    'ltex',
    'pylsp',
    'lua_ls',
    'bashls',
    'tsserver',
})


lsp.format_on_save({
    format_opts = {
        async = false,
        timeout_ms = 1000,
    },
    servers = {
        ['pylsp'] = { 'python' },
        ['lua_ls'] = { 'lua' },
        ['null-ls'] = { 'typescript', 'javascript' },
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

vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        source = "if_many",
    },
    float = {
        border = "rounded",
        source = "always",
    },
    severity_sort = true,
})

vim.o.updatetime = 1000
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            border = "rounded",
            source = "always"
        })
    end
})

local mason_registry = require("mason-registry")

local function ensure_installed(pkg)
    if not mason_registry.is_installed(pkg) then
        local p = mason_registry.get_package(pkg)
        p:install()
    end
end

ensure_installed("prettierd")
