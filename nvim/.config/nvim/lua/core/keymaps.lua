-- this file contains all my keymaps
-- <leader> needs to be set up in init.lua, right before setting up lazy!

-- :h keycodes for notation
-- if some keys aren't working, see :h :map-special-keys
-- for example, <C-m> is treated as <Esc>. this will inevitably cost you tens of
-- minutes of pain in the future when you will bind something to <C-m>.

-- what's the difference between <cr> and <enter>? nothing.
-- what's the difference between : and <cr>? : requires you to be in normal
-- mode, while <cmd> can be invoked from any mode. this lets you
-- programmatically execute commands even from insert mode. just remember to
-- include a corresponding <cr> for every <cmd>.

local keymap = vim.keymap.set

-- this interferes with the command mode <c-f> menu.
-- keymap({ 'n', 'i', 'v' }, '<C-c>', '<esc>')

-- escape terminal mode because the default binding makes no sense like what???
keymap('t', '<Esc>', [[<C-\><C-n>]])

-- considering using these...
-- keymap('i', 'jk', '<Esc>')
-- keymap('i', 'kj', '<Esc>')

-- paste recently selected text
keymap('n', '<leader>p', '"0p')
keymap('n', '<leader>P', '"0P')

keymap('n', '<leader>V', 'ggVG')

-- keymap('n', '<c-n>', function() vim.cmd('Explore') end)
-- recall that %:p:h is the name of the current buffer's directory
-- keymap('n', '<c-n>', function() vim.cmd('Explore %:p:h') end)
-- open netrw to the right and with specified width
-- keymap('n', '<leader>ex', function() vim.cmd('30Vexplore!') end)

-- remove annoying mappings
keymap({ 'n', 'v' }, '<c-f>', '')
keymap({ 'n', 'v' }, '<c-b>', '')
keymap('i', '<c-a>', '')
keymap('n', '<c-q>', '')
keymap('n', 'U', '')
keymap('n', 'gs', '')
-- no spellchecking related binds
keymap('n', 'zg', '')
keymap('n', 'zw', '')
-- i don't even know what this bind does but it's conflicting with my qmk combos
keymap('n', "<C-'>", '')

-- toggle 'clear search'
keymap('n', '<leader>cs', '<cmd>set hls!<cr>')

-- movement should work how you expect even if a line is really long
keymap('n', 'j', 'gj')
keymap('n', 'k', 'gk')
-- TODO put these in a "if wrap is enabled" block or something
-- keymap('n', '0', 'g0')
-- keymap('n', '$', 'g$')
-- keymap('n', '^', 'g^')

-- easier navigation between windows (not needed if vim-tmux-navigator present)
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
keymap('n', '<c-up>', '<c-u>zz')
keymap('n', '<c-down>', '<c-d>zz')
keymap('n', '<s-up>', '<c-u>zz')
keymap('n', '<s-down>', '<c-d>zz')

keymap('n', 'n', 'nzz')
keymap('n', 'N', 'Nzz')

-- easily open config
keymap('n', '<leader>ni', '<cmd>edit ~/.config/nvim/init.lua<cr>')
keymap('n', '<leader>nk', '<cmd>edit ~/.config/nvim/lua/core/keymaps.lua<cr>')
keymap('n', '<leader>nm', '<cmd>edit ~/.config/nvim/lua/core/misc-vim-stuff.lua<cr>')

-- alternate file
-- unfortunately, <tab> seems to be treated the same as <c-^>
-- keymap('n', '<Tab>', '<c-^>')
-- keymap('n', '[j', '<c-o>')
-- keymap('n', ']j', '<c-i>')
keymap('n', '<leader>a', '<cmd>b#<cr>')

-- 'go here' - change vim directory to the current buffer's path
keymap('n', '<leader>gh', function()
    vim.cmd('cd %:p:h')
end, {
    desc = 'go here - change cwd to match current buffer'
})

-- one eyed fighting kirby - use with \1 in a :s command for regex magic
keymap('c', '<C-k>', [[\(.*\)]])

-- buffer stuff
keymap('n', '<leader>bb', '<cmd>buffers<cr>')
-- keymap('n', '<leader>bn', '<cmd>bn<cr>')
-- keymap('n', '<leader>bp', '<cmd>bp<cr>')
-- keymap('n', '<leader>bq', '<cmd>bd<cr>')
-- keymap('n', '<leader>bQ', '<cmd>bd!<cr>')
keymap('n', '<leader>bd', '<cmd>bd<cr>')
-- keymap('n', '<leader>q', '<cmd>bd<cr>')
keymap('n', '<leader>bD', '<cmd>bd!<cr>')

-- TODO consider making this close neovim if you try to close the last remaining
-- buffer
keymap('n', '<BS>', '<cmd>bd<cr>')

-- more remaps
keymap('n', '<leader>w', '<cmd>w<cr>')
keymap('n', '<leader>ed', '<cmd>edit<cr>')
keymap('n', '<leader>so', function()
    print('sourced!')
    vim.cmd('source')
end)

-- square bracket fun time [ [ [ ] ] ]
keymap('n', '[b', vim.cmd.bprevious)
keymap('n', ']b', vim.cmd.bnext)
keymap('n', ']c', '<cmd>cnext<cr>')
keymap('n', '[c', '<cmd>cprev<cr>')
keymap('n', ']l', '<cmd>lnext<cr>')
keymap('n', '[l', '<cmd>lprev<cr>')

-- "change inside ___" motions but reversed
keymap('n', 'cr"', '?"<cr><cmd>nohlsearch<cr>ci"')
keymap('n', "cr'", "?'<cr><cmd>nohlsearch<cr>ci'")
keymap('n', 'cr`', '?`<cr><cmd>nohlsearch<cr>ci`')
keymap('n', 'cr(', '?(<cr><cmd>nohlsearch<cr>ci(')
keymap('n', 'cr[', '?[<cr><cmd>nohlsearch<cr>ci[')
keymap('n', 'cr{', '?{<cr><cmd>nohlsearch<cr>ci{')
keymap('n', 'cr<', '?<<cr><cmd>nohlsearch<cr>ci<')

keymap('n', 'ciq', 'ci"')
keymap('n', 'crq', '?"<cr><cmd>nohlsearch<cr>ci"')

-- add argument to function
-- keymap('n', '<leader>a', '$F)i, ')

-- put markdown headings into the quickfix list for easy navigation
-- TODO just make this a separate plugin
keymap('n', 'md', '<cmd>vimgrep /^\\#/ %<cr><cmd>copen<cr>')

-- navigate between git merge conflict markers (do i use this?)
-- keymap('n', '[g', '?<<<<<<<<cr>')
-- keymap('n', ']g', '/<<<<<<<<cr>')
