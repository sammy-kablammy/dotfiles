override_whitespace_settings("spaces", 2)

vim.keymap.set("n", "gX", function()
    vim.ui.open("https://tree-sitter.github.io/tree-sitter/using-parsers#pattern-matching-with-queries")
end)
