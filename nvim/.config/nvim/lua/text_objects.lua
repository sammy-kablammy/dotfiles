-- the whole buffer
vim.keymap.set("x", "gG", function()
    local num_lines_in_buf = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    vim.api.nvim_buf_set_mark(0, "<", 1, 0, {})
    vim.api.nvim_buf_set_mark(0, ">", num_lines_in_buf, 999999, {})
    vim.api.nvim_feedkeys("gv", "n", true)
end)
vim.keymap.set("o", "gG", ":normal vgG<cr>")

-- bAckticks
vim.keymap.set("o", "ia", "i`")
vim.keymap.set("o", "aa", "a`")
