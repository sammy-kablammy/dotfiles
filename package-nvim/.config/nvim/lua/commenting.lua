-- See :h commenting
local function comment_after()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    local current_line = vim.fn.getline(cursor[1])
    vim.fn.setline(cursor[1], current_line .. ' ' .. commentmarker .. ' ')
    vim.api.nvim_feedkeys("A", "n", true)
end
vim.keymap.set("n", "gcA", comment_after, { desc = "comment after line" })
-- gca conflicts with gc<around> so it can only be gcA
-- vim.keymap.set("n", "gca", comment_after, { desc = "comment after line" })
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

--[[

Todo highlighting

With :match, :2match, and :3match you can match up to three things at a time.
But matchadd() lets you add arbitrarily many.
- match example    :match MyHighlightGroup /some_regex/

Another (possibly better) way to do this is via extmarks, but that would require
manually running through all lines visible on screen to create the extmarks.

things to come back to:
- quickfix/loclist integration
- possible signcolumn

--]]
local function highlight_todos()
    if vim.bo.commentstring == "" then
        -- either the commentstring hasn't been defined yet, or this buffer just
        -- doesn't have one

        -- print("No commentstring! Cannot highlight todos") this is really annoying actually
        return
    end

    -- You can get colors from builtin highlight groups like this:
    -- local color = vim.fn.synIDattr(vim.fn.hlID("TermCursor"), "bg#")

    local blue = "gui=bold guifg=#ffffff guibg=#227799"
    local yellow = "gui=bold guifg=#ffffff guibg=#888800"
    local keywords = {
        ["TO-DO"] = blue,
        ["TODO"] = blue,
        ["NOTE"] = blue,
        ["WARN"] = yellow,
        ["HACK"] = yellow,
    }
    for keyword, hlcommand in pairs(keywords) do
        -- note that there is actually a builtin Todo hlgroup in vim if you
        -- wanted to use that

        -- create highlight group for the thing
        local hlgroup = "SamHighlight" .. keyword
        -- see ':h attr-list' for things that can go after 'gui='
        vim.cmd.highlight(hlgroup .. " " .. hlcommand)

        -- Since the :match regex has slashes, vim gets confused when there are
        -- unescaped slashes in the commentstring
        local commentstring = vim.fn.substitute(vim.bo.commentstring, '/', [[\\/]], "g")

        local pattern = string.gsub(commentstring, "%%s", keyword)
        if pattern == nil then
            -- this would mean commentstring didn't contain %s, which i believe
            -- should be guaranteed?
            print("does this ever happen?")
            return
        end
        pattern = pattern .. '.*$'
        local match_id_nr = vim.fn.matchadd(hlgroup, pattern)
        if match_id_nr == -1 then
            print("todo commenting failed. matchadd returned -1. idk")
        end
    end
end
-- Need to use an autocommand because 'commentstring' isn't set right away
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    -- :match is actually window-local, not buffer. so need to do this on a
    -- window autocmd. but also we want it on bufenter because sometimes it
    -- doesn't work with just the WinEnter
    callback = highlight_todos,
})
