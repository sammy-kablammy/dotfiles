-- a better "custom textobject" framework would have you define callbacks to
-- pick the start and end, then do something like this:
-- create_textobject(find_start_callback, find_end_callback, keymap)
-- But how would this work for inside and around?

-- Things to test when creating custom text objects to make sure they all behave
-- intuitively:
-- * Cursor on a previous line, COULD do nothing OR select the next one found
-- * Cursor before object, same line should select object
-- * Cursor at the beginning char of the object should select object
-- * Cursor in the middle of the object should select object
-- * Cursor at the end char of the object should select object
-- * Cursor after object, same line should do nothing
-- * Cursor on a later line should do nothing
-- * Also consider whether this type of object can be nested

-- TODO custom operator to turn a comment into a big bar style comment, e.g. 80
-- lines of the first token of commentstring but with the text in the middle of
-- it. so like "HEADER" becomes "##...## HEADER ##...##"

-- TODO make sure all textobjects follow the same format and have descriptions



-- ok here are my textobjects



-- the whole buffer
vim.keymap.set("x", "gG", function()
    local num_lines_in_buf = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    vim.api.nvim_buf_set_mark(0, "<", 1, 0, {})
    vim.api.nvim_buf_set_mark(0, ">", num_lines_in_buf, 999999, {})
    vim.api.nvim_feedkeys("gv", "n", true)
end)
vim.keymap.set("o", "gG", ":normal vgG<cr>")

-- bAckticks
vim.keymap.set("o", "ia", "i`")
vim.keymap.set("o", "aa", "a`")



-- experimental comment objects
-- function assumes 'inner', can override to 'around'
function select_comment(is_around)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]
    local cursor_col = cursor[2]

    if vim.bo.commentstring == "" then
        print("No commentstring!")
        return
    end
    -- we don't "correctly" parse commentstring, just the first 'token' of it
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    -- print("Comment marker is '" .. commentmarker .. "'")

    local is_match = string.find(vim.fn.getline(cursor_line), commentmarker, 1, true)
    if not is_match then
        return
    end

    -- test comment
    -- it's multiple
    -- lines
    -- long
    local and_the_comment_has_some = "code after it"

    -- search upward until no longer matches, put marker just before
    local linenum = cursor_line
    local is_comment = string.find(vim.fn.getline(linenum), commentmarker, 1, true)
    while is_comment do
        linenum = linenum - 1
        is_comment = string.find(vim.fn.getline(linenum), commentmarker, 1, true)
    end
    local comment_start_linenum = linenum + 1
    -- search downward until no longer matches, put marker just before
    linenum = cursor_line
    is_comment = string.find(vim.fn.getline(linenum), commentmarker, 1, true)
    while is_comment do
        linenum = linenum + 1
        is_comment = string.find(vim.fn.getline(linenum), commentmarker, 1, true)
    end
    local comment_end_linenum = linenum - 1

    local endcol = #vim.fn.getline(comment_end_linenum) - 1
    if is_around then
        endcol = 9999999
    end

    vim.api.nvim_buf_set_mark(0, "<", comment_start_linenum, 0, {})
    vim.api.nvim_buf_set_mark(0, ">", comment_end_linenum, endcol, {})
    vim.api.nvim_feedkeys("gv", "n", true)
end
vim.keymap.set("x", "ig", function() select_comment(false) end, { desc = "inside comment" })
vim.keymap.set("o", "ig", ":normal vig<cr>")
vim.keymap.set("x", "ag", function() select_comment(true) end, { desc = "around comment"})
vim.keymap.set("o", "ag", ":normal vag<cr>")

-- ooOOooooh try gcig it's really cool

-- TODO allow non visual-line mode to be used, so we can delete EOL comments.
-- would be very very useful (ok maybe not 'very very' but it would be neat)
local try_eol_here = 20 -- delete me



-- experimental "inside slash" for filepaths
-- TODO need 'i/' to change parts of a filepath

-- function assumes 'inner', can override to 'around'.
-- i think this object would be easiest to use if it only works on current line.
function select_slash(is_around)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]
    local cursor_col = cursor[2] + 1

    local line = vim.fn.getline(cursor_line)

    -- search leftward until slash or line start, save pos just before
    local startslash = cursor_col
    -- TODO is there not a better lua way to get char at string idx?
    while startslash > 0 and string.sub(line, startslash, startslash) ~= '/' do
        startslash = startslash - 1
    end
    -- search leftward until slash or line start, save pos just before
    local endslash = cursor_col + 1
    while endslash < #line and string.sub(line, endslash, endslash) ~= '/' do
        endslash = endslash + 1
    end
    endslash = endslash - 2
    print(startslash, endslash)

    -- /test/filepath/here/

    if is_around then
        startslash = startslash - 1
        endslash = endslash + 1
    end

    vim.api.nvim_buf_set_mark(0, "<", cursor_line, startslash, {})
    vim.api.nvim_buf_set_mark(0, ">", cursor_line, endslash, {})
    vim.api.nvim_feedkeys("gv", "n", true)
end
vim.keymap.set("x", "i/", function() select_slash(false) end)
vim.keymap.set("o", "i/", ":normal vi/<cr>")
vim.keymap.set("x", "a/", function() select_slash(true) end)
vim.keymap.set("o", "a/", ":normal va/<cr>")
