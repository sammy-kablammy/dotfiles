create_filetype_snippets({
    ["p"] = 'print("$1")',
    ["f"] = 'for k, v in pairs(mytable) do\n    $1\nend',
    ["v"] = 'vim.keymap.set("n", "<leader>$1", "", { desc = "" })',
    ["i"] = 'if $1 then\nend',
    ["a"] = 'vim.api.nvim_create_autocmd({ "BufEnter" }, {\n' ..
            '    callback = function(ev)\n' ..
            '        ${1:vim.print(ev)}\n' ..
            '    end,\n' ..
            '})'
})

vim.b.sam_documentation_url = "https://www.lua.org/manual/5.1/manual.html"

-- i'm defining a section as a line of a bunch of dashes
vim.keymap.set({ "n", "v" }, "[[", function()
    vim.fn.search("^---", "b")
end, { desc = "previous section", buffer = true })
vim.keymap.set({ "n", "v" }, "]]", function()
    vim.fn.search("^---")
end, { desc = "next section", buffer = true })
