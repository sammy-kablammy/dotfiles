vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.b.sam_override_whitespace_settings = true

vim.bo.formatoptions = "trqnj"
vim.b.sam_override_formatoptions = true

vim.keymap.set("n", "<leader><enter>", "<cmd>!typst compile %<cr>", { desc = "Typst compile" })

vim.keymap.set({ "n", "v" }, "gl", listify, {
    desc = "listify",
    buffer = true,
})
