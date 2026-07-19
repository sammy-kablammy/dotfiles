--[[

diagram/flowcharting tool. no special syntax or directives, just plain text.

Sorta like venn.nvim but focusing more on textobjects than visual selections
https://github.com/jbyuki/venn.nvim

key actions are
- create boxes floating in the void
- cursor around to select boxes, move boxes around
- draw arrows between boxes

what this is not: a magic buffer type that renders different characters on
screen than are contained in the underlying file

Populated box is like this

+------+
| Test |
+------+

Minimum possible empty box is this:

+---+
|   |
+---+

Should boxes be allowed to contain other boxes?

We're doing this the Vim way. simple operators like "change inside box", delete
around box, select a box. Create a box around word, like vim-surround, would
also be cool.

We can use extmarks to keep track of boxes even if they move, adjusting arrows
accordingly

Drawing may overwrite existing text in the buffer. Undo is your friend.

Use "co" for "change bOx" etc. unless i can find a better mnemonic.

--]]

-- Create an empty box, appending after the given line num.
-- 1-based line, 0-based col (same convention as nvim_win_get_cursor and vim.fn.append)
create_box = function(line, col)
    -- Use sensible line numbering (convert api-indexing to 1-based lines)
    -- line = line - 1

    -- Not sure if we want to actually use the column yet
    col = 0

    local indent = 0
    -- vim.api.nvim_buf_set_text(0, line, col, line, col, { "+---+", })
    vim.fn.append(line + 0, "+---+")
    vim.fn.append(line + 1, "|   |")
    vim.fn.append(line + 2, "+---+")
end

debug_cap = 1000

-- Attempt to find a box with the given top left corner. If not exactly the
-- corner, will search upward and leftward for the top left corner.
-- Params should be 1-based lines, 0-based columns
get_box_bounds = function(line, col)
    if debug_cap < 1 then
        return
    end
    debug_cap = debug_cap - 1
    -- NOTE steps:
    -- Find box under cursor
    -- Cursor could either be on the border, or inside the box.
    -- If on the border, just trace the border around until you know the bounds.
    -- If inside, walk up/left until you find the border, then same as case 1.

    -- Start by assuming the cursor sits on the top row. We'll recurse if this
    -- assumption fails.
    print("Start")

    -- Find top left
    local box_topleft
    local i = col
    local cursorline = vim.fn.str2list(vim.fn.getline(line))
    while i >= 0 do
        if debug_cap < 1 then
            print("too much recursion 1")
            return
        end
        debug_cap = debug_cap - 1
        local ch = string.sub(vim.fn.getline(line), i, i + 1)
        print("ch", ch)
        if ch == '+' then
            box_topleft = i
            break
        end
        i = i - 1
    end
    print(box_topleft == nil, line >= 1)
    if box_topleft == nil and line >= 1 then
        -- Didn't find topleft, maybe the cursor is currently inside a diagram
        -- box? Try going up a line
        print("What", line - 1, col)
        return get_box_bounds(line - 1, col)
    end
    print("got topleft:", box_topleft)
    -- Find top right
    local box_topright
    i = i + 1 -- advance past top left
    while i <= #cursorline do
        if debug_cap < 1 then
            print("too much recursion 2")
            return
        end
        debug_cap = debug_cap - 1
        local ch = string.sub(vim.fn.getline(line), i, i + 1)
        if ch == '+' then
            box_topright = i
            break
        end
        i = i + 1
    end
    -- print("got topright:", box_topright)
    print("topleft, topright", box_topleft, box_topright)

    -- Now find bottom left
    local bottom_line = line + 1
    while '|' == string.sub(vim.fn.getline(bottom_line), box_topleft,  box_topleft + 1) do
        bottom_line = bottom_line + 1
    end
    -- print("bottom left is", bottom_line)
    -- assert next line is in fact a '+'
    if '+' ~= string.sub(vim.fn.getline(bottom_line), box_topleft, box_topleft + 1) then
        -- Failed
        print("Couldn't find bottom left")
        return
    end

    -- Assert the bottom right corner is where we expect it to be
    -- print(bottom_line, box_topright)
    -- print(string.sub(vim.fn.getline(bottom_line), box_topright, box_topright + 0))
    if '+' ~= string.sub(vim.fn.getline(bottom_line), box_topright, box_topright + 0) then
        -- Failed
        print("Bottom right is not in expected position")
        return
    end
    -- print("Bottom right is", bottom_line, box_topright)

    return {
        top_line = line,
        bottom_line = bottom_line,
        left_col = box_topleft,
        right_col = box_topright,
    }

end

vim.keymap.set("n", "cd", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    create_box(cursor[1], cursor[2])
end, { desc = "create diagram" })
vim.keymap.set("x", "ad", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local bounds = get_box_bounds(cursor[1], cursor[2])
    if bounds == nil then
        return
    end
    -- vim.print(bounds)
    vim.api.nvim_buf_set_mark(0, "<", bounds.top_line, bounds.left_col, {})
    vim.api.nvim_buf_set_mark(0, ">", bounds.bottom_line, bounds.right_col, {})
    vim.api.nvim_feedkeys("gv", "n", false)
end, { desc = "around diagram" })
vim.keymap.set("o", "ad", ":normal vad<cr>", { desc = "around diagram" })
vim.keymap.set("x", "id", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local bounds = get_box_bounds(cursor[1], cursor[2])
    if bounds == nil then
        return
    end
    -- For now assuming every box is 3 lines tall (top bound, text, bottom bound)
    vim.api.nvim_buf_set_mark(0, "<", bounds.top_line + 1, bounds.left_col + 2, {})
    vim.api.nvim_buf_set_mark(0, ">", bounds.top_line + 1, bounds.right_col - 2, {})
    vim.api.nvim_feedkeys("gv", "n", false)
end, { desc = "inside diagram" })
vim.keymap.set("o", "id", ":normal vid<cr>", { desc = "inside diagram" })

-- -- Autocommand such that, when the text inside the box is edited, we
-- -- automatically expand the box.
-- vim.api.nvim_create_autocmd("TextChangedI", {
--     callback = function(ev)
--         -- If cursor is inside a box, expand
--     end,
--     desc = "Diagram box expansion monitor",
-- })

--[[
+---+
|   |
+---+
--]]
