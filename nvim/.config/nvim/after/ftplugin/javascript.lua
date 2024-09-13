vim.keymap.set("n", "<leader><enter>", "<cmd>!node %<cr>", { buffer = true })
vim.b.sam_documentation_url = "https://developer.mozilla.org/en-US/"
InsertMap("f", "for (let i = 0; i < len; i++) {<enter>}<esc>O")
InsertMap("p", 'console.log("")<left><left>')
InsertMap("i", 'document.getElementById("")<left><left>')
