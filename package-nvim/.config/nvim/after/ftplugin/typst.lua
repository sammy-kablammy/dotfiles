override_whitespace_settings("spaces", 2)

vim.bo.formatoptions = "trqnj"
vim.b.sam_override_formatoptions = true

vim.keymap.set("n", "<leader><enter>", "<cmd>!typst compile %<cr>", { desc = "Typst compile" })

vim.keymap.set({ "n", "v" }, "gl", listify, {
    desc = "listify",
    buffer = true,
})
