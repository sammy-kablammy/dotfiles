vim.o.formatexpr = ""

vim.keymap.set("n", "gO", [[<cmd>vimgrep /^#\{1,6\} /j % | copen<cr>]], { desc = "markdown: table of contents", buffer = true })
vim.keymap.set('n', '<leader>ma', 'o[](<c-r>#)<esc>^', { desc = "markdown: link to alternate file", buffer = true })

-- this is old. should probably use gqip instead.
vim.keymap.set('n', '<leader>mp', 'vip:%!fmt<cr>', { desc = "markdown: format paragraph", buffer = true })
