-- view pdfs in vim!! hoorayyy!!! yippeee!!! (kind of, and only if your 'less' supports it)
vim.cmd("norm ggdG")
vim.bo.readonly = true
vim.cmd("read ! less %")

-- come to think of it, just do "less file.pdf | vimless"
