-- this file contains all my keymaps

-- <leader> needs to be set up in init.lua, right before setting up lazy!

-- if some keys aren't working, see :h :map-special-keys
-- for example, <C-m> is treated as <Esc>. this will inevitably cost you tens of
-- minutes of pain in the future when you will bind something to <C-m>.

local keymap = vim.keymap.set

keymap({ 'n', 'i', 'v' }, '<C-c>', '<esc>')

-- escape terminal mode because the default binding makes no sense like what???
keymap('t', '<Esc>', [[<C-\><C-n>]])

-- remove annoying mappings
keymap('n', '<c-f>', '')
keymap('n', '<c-b>', '')
keymap('i', '<c-a>', '')
keymap('n', '<c-q>', '')
keymap('n', '?', '') -- ?query is just /query followed by N
keymap('n', 'U', '')

-- toggle 'clear search'
keymap('n', '<leader>cs', '<cmd>set hls!<cr>')

-- movement should work how you expect even if a line is really long
keymap('n', 'j', 'gj')
keymap('n', 'k', 'gk')
-- TODO put these in a "if wrap is enabled" block or something
-- keymap('n', '0', 'g0')
-- keymap('n', '$', 'g$')
-- keymap('n', '^', 'g^')

-- easier navigation between windows
keymap('n', '<c-h>', '<c-w>h')
keymap('n', '<c-j>', '<c-w>j')
keymap('n', '<c-k>', '<c-w>k')
keymap('n', '<c-l>', '<c-w>l')

-- only
keymap('n', '<leader>o', '<cmd>only<cr>')

-- open newest buffer in vsplit and go back to old file
keymap('n', '<leader>v', '<cmd>vsplit<cr><cmd>bprev<cr><c-w>r')

-- scroll up and down without getting disoriented
keymap('n', '<c-d>', '<c-d>zz')
keymap('n', '<c-u>', '<c-u>zz')

-- easily open config
keymap('n', '<leader>ni', '<cmd>edit ~/.config/nvim/init.lua<cr>')
keymap('n', '<leader>nk', '<cmd>edit ~/.config/nvim/lua/core/keymaps.lua<cr>')
keymap('n', '<leader>nm', '<cmd>edit ~/.config/nvim/lua/core/misc-vim-stuff.lua<cr>')

-- alternate file
keymap('n', '<Tab>', '<c-^>')

-- 'go here' - change vim directory to the current buffer's path
keymap('n', '<leader>gh', function()
    vim.cmd('cd %:p:h') end, {
    desc = 'go here - change cwd to match current buffer'
})

-- one eyed fighting kirby - use with \1 in a :s command for regex magic
keymap('c', '<C-k>', [[\(.*\)]])

-- buffer stuff
keymap('n', '<leader>bb', '<cmd>buffers<cr>')
keymap('n', '<leader>bn', '<cmd>bn<cr>')
keymap('n', '<leader>bp', '<cmd>bp<cr>')
keymap('n', '<leader>bq', '<cmd>bd<cr>')
keymap('n', '<leader>bQ', '<cmd>bd!<cr>')
keymap('n', '<leader>bd', '<cmd>bd<cr>')
keymap('n', '<leader>q', '<cmd>bd<cr>')
keymap('n', '<leader>bD', '<cmd>bd!<cr>')

-- tab stuff
keymap('n', '<leader>te', '<cmd>tabe<cr>')
keymap('n', '<leader>tq', '<cmd>tabclose<cr>')
keymap('n', '<leader>tn', '<cmd>tabnext<cr>')
keymap('n', '<leader>tp', '<cmd>tabprevious<cr>')
keymap('n', '<leader>tt', '<cmd>tabs<cr>')

-- more remaps
keymap('n', 'ZW', '<cmd>w<cr>')
keymap('n', '<leader>w', '<cmd>w<cr>')
keymap('n', '<leader>ed', '<cmd>edit<cr>')
keymap('n', '<leader>so', function()
    print('sourced!')
    vim.cmd('source')
end)

-- square bracket fun time [ [ [ ] ] ]
keymap('n', '[b', vim.cmd.bprevious)
keymap('n', ']b', vim.cmd.bnext)

-- quickfix list -- TODO dear god sort out these keymaps
-- keymap('n', '<leader>qf', '<cmd>copen<cr>')
-- keymap('n', '<leader>co', '<cmd>copen<cr>')
-- keymap('n', '<leader>cq', '<cmd>cclose<cr>')
-- keymap('n', '<leader>cf', '<cmd>cfirst<cr>')
-- keymap('n', '<leader>cl', '<cmd>clast<cr>')
-- keymap('n', '<leader>cn', '<cmd>cn<cr>')
-- keymap('n', '<leader>cp', '<cmd>cp<cr>')
-- keymap('n', ']t', '<cmd>cn<cr>')
-- keymap('n', '[t', '<cmd>cp<cr>')

-- "change inside ___" motions but reversed
keymap('n', 'cr"', '?"<cr><cmd>nohlsearch<cr>ci"')
keymap('n', "cr'", "?'<cr><cmd>nohlsearch<cr>ci'")
keymap('n', 'cr`', '?`<cr><cmd>nohlsearch<cr>ci`')
keymap('n', 'cr(', '?(<cr><cmd>nohlsearch<cr>ci(')
keymap('n', 'cr[', '?[<cr><cmd>nohlsearch<cr>ci[')
keymap('n', 'cr{', '?{<cr><cmd>nohlsearch<cr>ci{')
keymap('n', 'cr<', '?<<cr><cmd>nohlsearch<cr>ci<')

-- add argument to function
-- keymap('n', '<leader>a', '$F)i, ')

-- put markdown headings into the quickfix list for easy navigation
-- TODO just make this a separate plugin
keymap('n', 'md', '<cmd>vimgrep /^\\#/ %<cr><cmd>copen<cr>')

-- navigate between git merge conflict markers (do i use this?)
-- keymap('n', '[g', '?<<<<<<<<cr>')
-- keymap('n', ']g', '/<<<<<<<<cr>')
