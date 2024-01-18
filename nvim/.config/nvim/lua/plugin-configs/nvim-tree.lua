-- typing <c-n> will find the current working directory and open it in nvim-tree
vim.keymap.set('n', '<c-n>', '<cmd>NvimTreeFindFileToggle<cr>')

-- easily close nvim-tree
vim.keymap.set('n', '<c-b>', '<cmd>NvimTreeClose<cr>')

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
        width = 40,
        side = "right",
        relativenumber = true,
        float = {
            enable = false,
            quit_on_focus_loss = true,
            open_win_config = {
                relative = "editor",
                border = "rounded",
                width = 50,
                height = 30,
                row = 1,
                col = 1,
            },
        }
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
})
