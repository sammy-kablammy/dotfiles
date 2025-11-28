vim.keymap.set("n", "<enter>", "<c-]>", { buffer = true })

-- some tables are messed up when not using the default tab size
vim.bo.tabstop = 8
vim.b.sam_override_whitespace_settings = true
