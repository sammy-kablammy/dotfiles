local builtin = require("telescope.builtin")

-- make sure you have ripgrep installed

-- you can use 'builtin.builtin' to find builtin pickers

local function map(lhs, rhs, desc)
    if desc then
        vim.keymap.set("n", "<leader>f" .. lhs, rhs, { desc = desc })
    else
        vim.keymap.set("n", "<leader>f" .. lhs, rhs, {})
    end
end

map("f", function()
    builtin.find_files({ hidden = true })
end, "find files")
map("h", builtin.help_tags, "help")
map("b", builtin.buffers, "buffers")
map("g", builtin.live_grep, "live grep")
map("o", builtin.oldfiles, "old files")
map("q", builtin.quickfix, "quickfix list")
map("l", builtin.loclist, "local list")
map("m", builtin.diagnostics, "diagnostics")
map("c", builtin.command_history, "command history")
map("p", builtin.planets, "planets") -- lol
map("k", builtin.keymaps, "keymaps")

-- these could come in handy
-- map('c', builtin.current_buffer_fuzzy_find, 'current buffer')
-- map('v', builtin.vim_options, '')
-- map('r', builtin.lsp_references, '')
-- map('t', builtin.treesitter, 'treesitter identifiers')
-- map('m', builtin.man_pages, '')
-- map('gi', builtin.git_commits, 'git commits')
-- map('gs', builtin.git_status, 'git status')

map("n", function()
    builtin.live_grep({
        search_dirs = {
            "~/notes/main",
        },
    })
end, "notes")

vim.keymap.set('n', '<leader>mt',
    '"tyy<cmd>lua require("telescope.builtin").live_grep()<cr><c-r>t',
    { desc = "markdown: telescope by tag" }
)
