vim.keymap.set('n', '<leader>u', function()
    vim.cmd.UndotreeToggle()
    vim.cmd.UndotreeFocus()
end)

vim.cmd("let g:undotree_DiffAutoOpen=0")
