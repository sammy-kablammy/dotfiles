-- https://github.com/numToStr/Comment.nvim

-- require('Comment').setup({
--     ---Add a space b/w comment and the line
--     padding = true,
--     ---Whether the cursor should stay at its position
--     sticky = true,
--     ---Lines to be ignored while (un)comment
--     ignore = nil,
--     ---LHS of toggle mappings in NORMAL mode
--     toggler = {
--         ---Line-comment toggle keymap
--         line = 'gcc',
--         ---Block-comment toggle keymap
--         block = 'gbc',
--     },
--     ---LHS of operator-pending mappings in NORMAL and VISUAL mode
--     opleader = {
--         ---Line-comment keymap
--         line = 'gc',
--         ---Block-comment keymap
--         block = 'gb',
--     },
--     ---LHS of extra mappings
--     extra = {
--         ---Add comment on the line above
--         above = 'gcO',
--         ---Add comment on the line below
--         below = 'gco',
--         ---Add comment at the end of line
--         eol = 'gcA',
--     },
--     ---Enable keybindings
--     ---NOTE: If given `false` then the plugin won't create any mappings
--     mappings = {
--         ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
--         basic = true,
--         ---Extra mapping; `gco`, `gcO`, `gcA`
--         extra = true,
--     },
--     ---Function to call before (un)comment
--     pre_hook = nil,
--     ---Function to call after (un)comment
--     post_hook = nil,
-- })



-- Now using ':h commenting' instead of comment.nvim
vim.keymap.set("n", "gcA", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    local current_line = vim.fn.getline(cursor[1])
    vim.fn.setline(cursor[1], current_line .. ' ' .. commentmarker .. ' ')
    vim.api.nvim_feedkeys("A", "n", true)
end)
vim.keymap.set("n", "gco", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    vim.fn.append(cursor[1], commentmarker .. ' ')
    vim.api.nvim_feedkeys("=jjA", "n", true)
end)
vim.keymap.set("n", "gcO", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    vim.fn.append(cursor[1] - 1, commentmarker .. ' ')
    vim.api.nvim_feedkeys("=kA", "n", true)
end)
