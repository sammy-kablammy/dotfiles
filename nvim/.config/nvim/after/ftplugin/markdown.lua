vim.keymap.set("n", "gO", [[<cmd>vimgrep /^#\{1,6\} /j % | copen<cr>]], { desc = "markdown: table of contents", buffer = true })
vim.keymap.set('n', '<leader>ma', 'o[](<c-r>#)<esc>^', { desc = "markdown: link to alternate file", buffer = true })

vim.o.formatexpr = ""

-- 'a' option is cool but it messes up lists and basically everything
vim.o.formatoptions = "trqnj"

-- make bulleted lists continue. i like having 'c' removed from formatoptions
-- for this to feel good.
-- this is IMPORTANT! 'fb:-' overrides 'b:-'. the 'fb' version will preserve
-- indentation in lists while the 'b' version does not, BUT the 'b' version will
-- auto insert new bullets on new lines.
-- NOTE! these kinda ruin gqip, so probably just don't enable them
-- vim.opt.com:remove("fb:-")
-- vim.opt.com:append("b:-")
-- vim.opt.com:append("b:1.")
