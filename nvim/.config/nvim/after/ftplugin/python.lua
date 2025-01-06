vim.keymap.set("n", "<leader><enter>", "<cmd>!python3 %<cr>")

InsertMap("p", 'print("")<left><left>')

vim.b.sam_documentation_url = "https://docs.python.org/3/library/index.html"

-- Install with 'pip install black', don't bother with Mason
vim.bo.formatprg = "black - --quiet"
