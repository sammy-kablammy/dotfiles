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
-- This will also need corresponding logic in every filetype to set the [[ keys
-- to navigate by sections defined in this same way. Again, organizing my files
-- by "object" or "operator" is weird. they should be organized by use case.
function sectionify()
    if vim.bo.commentstring == "" then
        print("Cannot create section because commentstring is empty")
        return
    end
    local commentmarker = vim.fn.split(vim.bo.commentstring)[1]
    local sectionmarker = string.sub(commentmarker, #commentmarker)
    local line = vim.trim(vim.fn.getline('.'))
    local TOTAL_HEADER_WIDTH = 80 -- Could probably derive this from signcolumn or another option
    local num_characters = TOTAL_HEADER_WIDTH - 1 - #line - 2 -- -2 because of spaces
    local newline = sectionmarker
    newline = newline .. string.rep(sectionmarker, num_characters / 2)
    newline = newline .. ' ' .. line .. ' '
    newline = newline .. string.rep(sectionmarker, num_characters / 2)
    if #newline < TOTAL_HEADER_WIDTH then
        newline = newline .. sectionmarker
    end
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    vim.fn.setline(lnum, newline)
end
vim.keymap.set({ "n", "v" }, "<leader>cs", function()
    sectionify()
end, { desc = "Create Section" })



-- TODO make sure all textobjects follow the same format and have descriptions

-- Should take a pass over all my custom objects and decide whether they should
-- be linewise or charwise. A custom textobject framework should give you a
-- simple bool to make objects linewise



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
-- This conflicts with alphabetic
-- vim.keymap.set("o", "ia", "i`")
-- vim.keymap.set("o", "aa", "a`")



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
    -- TODO use vim.regex instead of string.find, and just replace %s with .*
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
-- vim.keymap.set("x", "ig", function() select_comment(false) end, { desc = "inside comment" })
-- vim.keymap.set("o", "ig", ":normal vig<cr>")
-- vim.keymap.set("x", "ag", function() select_comment(true) end, { desc = "around comment"})
-- vim.keymap.set("o", "ag", ":normal vag<cr>")
-- vim.keymap.set("x", "ic", function() select_comment(false) end, { desc = "inside comment" })
-- vim.keymap.set("o", "ic", ":normal vig<cr>")
-- vim.keymap.set("x", "ac", function() select_comment(true) end, { desc = "around comment"})
-- vim.keymap.set("o", "ac", ":normal vag<cr>")

-- TODO look into require("vim._comment")'s textobject function. this might be
-- builtin nowadays... hmm no it doesn't handle going up lines. it only goes
-- down from the cursor position. is that intentional?
vim.keymap.set("x", "ig", require("vim._comment").textobject, { desc = "inside comment" })
vim.keymap.set("o", "ig", ":normal vig<cr>")
vim.keymap.set("x", "ag", require("vim._comment").textobject, { desc = "around comment"})
vim.keymap.set("o", "ag", ":normal vag<cr>")
vim.keymap.set("x", "ic", require("vim._comment").textobject, { desc = "inside comment" })
vim.keymap.set("o", "ic", ":normal vig<cr>")
vim.keymap.set("x", "ac", require("vim._comment").textobject, { desc = "around comment"})
vim.keymap.set("o", "ac", ":normal vag<cr>")

-- TODO we need a way to delete end of line comments. This should be pretty easy
-- as a textobject if you just allow matching 'cms' not at the start of the file
--
-- should bind to ie? like cie to change or die to delete


-- ooOOooooh try gcig it's really cool

-- TODO allow non visual-line mode to be used, so we can delete EOL comments.
-- would be very very useful (ok maybe not 'very very' but it would be neat)
local try_eol_here = 20 -- delete me

-- can the filepath object be replaced with expand("<cfile>") ? or maybe the
-- 'i/' is only for a PART of a filepath, and 'iu' is for "inside URI"
-- TODO broken
vim.keymap.set("o", "iu", function()
    local url_strings = vim.ui._get_urls()
end, { desc = "inside URI" })

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
-- ^  ^^^         ^ ^    ^^  test all these cursor starting positions
-- actually... could we make some kind of testing framework to verify that we don't break this in the future?

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



-- Only works for 'inside' objects and only works on a single line.
-- Need to think about how we want to match multiline objects
function select_custom_textobject(start_checker, end_checker)

    -- basically the plan is to move the cursor left while start_checker returns
    -- true, and move right while end_checker returns true.
    --
    -- The checker functions should take in the current character and return
    -- true if that character is part of the object.

    if end_checker == nil then
        end_checker = start_checker
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]
    -- +1 because nvim api has 0-based columns but lua string.sub() indices are 1-based:
    -- (but where is string.sub? this comment is no longer correct)
    local cursor_col = cursor[2] + 1

    -- convert string into list/table of chars
    local line = vim.fn.str2list(vim.fn.getline(cursor_line))
    for i, v in ipairs(line) do
        line[i] = vim.fn.nr2char(v)
    end

    -- if cursor col doesn't match, don't try to match anything more
    if line[cursor_col] == nil or not start_checker(line[cursor_col]) or not end_checker(line[cursor_col]) then
        return
    end

    -- Find left boundary of object
    local object_start_col = cursor_col
    local maxiters = 100000
    local iters = 0
    while line[object_start_col] ~= nil and start_checker(line[object_start_col]) and iters < maxiters do
        -- what happens if we go off the end of the line? Nothing. it should just work.
        object_start_col = object_start_col - 1
        maxiters = maxiters + 1
    end
    -- Find right boundary of object
    local object_end_col = cursor_col
    maxiters = 10
    iters = 0
    while line[object_end_col] ~= nil and end_checker(line[object_end_col]) and iters < maxiters do
        -- what happens if we go off the end of the line?
        object_end_col = object_end_col + 1
        maxiters = maxiters + 1
    end
    -- print(object_start_col, object_end_col)

    -- idk why
    object_end_col = object_end_col - 2

    vim.api.nvim_buf_set_mark(0, "<", cursor_line, object_start_col, {})
    vim.api.nvim_buf_set_mark(0, ">", cursor_line, object_end_col, {})
    vim.api.nvim_feedkeys("gv", "n", true)

end

-- try selecting ints
-- "in" Currently conflicts with incremental selection in
vim.keymap.set("x", "iN", function()
    select_custom_textobject(false, false, function(char)
        return string.find("0123456789", char) ~= nil
    end, function(char)
        return string.find("0123456789", char) ~= nil
    end)
end, { desc = "inside Number implementation" })
vim.keymap.set("o", "iN", ":normal viN<cr>", { desc = "inside Number" })

-- selecting alphabetic, using the same predicate func for both
vim.keymap.set("x", "ia", function()
    select_custom_textobject(function(char)
        local f = vim.fn.char2nr
        local ch = f(char)
        return (ch >= f'A' and ch <= f'Z') or (ch >= f'a' and ch <= f'z')
    end)
end)
vim.keymap.set("o", "ia", ":normal via<cr>")

-- TODO add 'inside number' and 'around number' objects that match words yes but
-- also decimal points and the negative sign. used in foo(hi, -1.23) to match
-- only the number without the closing paren or comma
