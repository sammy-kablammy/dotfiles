InsertMap("f", "for k, v in pairs(mytable) do<cr>end<esc>O")
InsertMap("p", 'print("")<left><left>')
InsertMap("v", 'vim.keymap.set("n", "<lt>leader>", "")<left><left><left><left><left><left>')
InsertMap("i", "if <cr>end<esc>kAthen<esc>4hi ")
-- this is ugly
InsertMap("a", [[vim.api.nvim_create_autocmd({ "BufEnter" }, {
callback = function()
end,
})<esc>kO]])

vim.b.sam_documentation_url = "https://www.lua.org/manual/5.1/manual.html"
