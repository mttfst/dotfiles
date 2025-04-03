-- highlight styling
vim.cmd("highlight SpellBad cterm=underline gui=undercurl guisp=Red")

-- Default language
vim.g.spellcheck_lang = "en_gb"

-- Spellcheck toggle
vim.keymap.set("n", "<leader>ss", function()
    vim.opt.spell = not vim.opt.spell:get()
    print("Spellcheck " .. (vim.opt.spell:get() and "enabled" or "disabled"))
end, { desc = "Toggle spell check" })

-- Spelllang toggle (en_gb <-> de)
vim.keymap.set("n", "<leader>sl", function()
    local current = vim.opt.spelllang:get()[1]
    local new_lang = current == "en_gb" and "de" or "en_gb"
    vim.opt.spelllang = new_lang
    vim.opt_local.spelllang = new_lang

    print("Spell language set to: " .. new_lang)
end, { desc = "Toggle spell language (en_gb/de)" })

-- Enable spellcheck for "textual" filetypes
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "gitcommit", "text", "tex", "plaintex", "latex" },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = vim.g.spellcheck_lang
    end,
})

-- Disable spellcheck by default for code filetypes
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "lua", "python", "typescript", "javascript",
        "bash", "sh", "c", "cpp", "fortran", "json"
    },
    callback = function()
        vim.opt_local.spell = false
    end,
})
