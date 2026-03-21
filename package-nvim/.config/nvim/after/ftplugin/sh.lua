InsertMap("i", "if [  ]; then<cr>fi<esc>k$7hi")
InsertMap("f", "for file in ./*; do<cr>done<esc>O")
InsertMap("w", "while [ ]; do<cr>done<esc>k$3hi")

-- not yet sure which mnemonic to choose for "shebang"
InsertMap("s", "#!/bin/sh")
InsertMap("h", "#!/bin/sh")

if vim.fn.executable("shellcheck") then
    vim.bo.makeprg = "shellcheck -f gcc %"
else
    -- from $VIMRUNTIME/compiler/bash.vim, for some reason it doesn't work there:
    vim.bo.makeprg = "bash -n %"
    vim.bo.errorformat = "%f: line %l: %m"
end
vim.keymap.set("n", "<leader><enter>", vim.cmd.make, { buffer = true })

-- Could use shfmt in addition to shellcheck
