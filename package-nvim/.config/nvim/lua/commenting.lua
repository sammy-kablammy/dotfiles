-- See :h commenting
local function comment_after()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    local current_line = vim.fn.getline(cursor[1])
    vim.fn.setline(cursor[1], current_line .. ' ' .. commentmarker .. ' ')
    vim.api.nvim_feedkeys("A", "n", true)
end
vim.keymap.set("n", "gcA", comment_after { desc = "comment after line" })
vim.keymap.set("n", "gca", comment_after { desc = "comment after line" })
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



-- things to come back to:
-- quickfix/loclist integration
-- todo, warn, hack, note
-- possible signcolumn



-- :match MyHighlightGroup /some_regex/
function SimplerTodo()
    if vim.bo.commentstring == "" and vim.api.nvim_buf_get_name(0) ~= "" then
        -- this is really annoying actually
        -- print("No commentstring! Cannot highlight todos")
        return
    end

    -- Trying to get colors from builtin highlight groups
    local color = vim.fn.synIDattr(vim.fn.hlID("TermCursor"), "bg#")

    -- see ':h attr-list' for things that can go after 'gui='
    vim.cmd.highlight("SimplerTodo gui=bold guifg=#eeeeee guibg=#227799")

    -- we don't "correctly" parse commentstring, just the first 'token' of it
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    -- Since the :match regex has slashes, vim gets confused when there are
    -- unescaped slashes in the commentstring
    commentmarker = vim.fn.substitute(commentmarker, '/', [[\\/]], "g") -- holy escaping

    local regex = '/' .. commentmarker .. " TODO.*$" .. '/'
    vim.cmd.match("SimplerTodo " .. regex)
end

-- Need to use an autocommand because 'commentstring' isn't set right away
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    -- :match is actually window-local, not buffer. so need to do this on a
    -- window autocmd. but also we want it on bufenter because sometimes it
    -- doesn't work with just the WinEnter
    callback = SimplerTodo,
})
